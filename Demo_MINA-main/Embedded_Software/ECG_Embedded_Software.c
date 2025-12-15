// gcc fpga_ecg_sdl.c -o fpga_ecg_sdl $(pkg-config --cflags --libs sdl2 SDL2_ttf) -O2 -lm
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdint.h>
#include <math.h>
#include <time.h>
#include <unistd.h>
#include <string.h>

#define BILLION  1000000000

// Write channel
#define START_BASE              (0x00000)
#define LDM_INPUT_BASE_PHYS     (0x10000>>2)
#define CRAM_INPUT_BASE_PHYS    (0x20000>>2)
#define WRAM_INPUT_BASE_PHYS    (0x30000>>2)
#define BRAM_INPUT_BASE_PHYS    (0x40000>>2)

// Read channel
#define DONE_BASE_PHYS          (0x00000)
#define LDM_OUTPUT_BASE_PHYS    (0x10000>>2)

#define FRACTIONAL_BITS 6
#define SCALE_FACTOR (1 << FRACTIONAL_BITS)

#define NumberOfPicture 100
#define d 1
#define SEG_LEN 320

#include "CGRA.h"
#include "FPGA_Driver.c"

// ------- SDL layout -------
#define WIDTH   1000
#define HEIGHT  360
#define TOP_BAR 28
#define BOT_BAR 28
#define PLOT_H  (HEIGHT - TOP_BAR - BOT_BAR)
// --------------------------

static inline double clampd(double v, double lo, double hi){
    return v < lo ? lo : (v > hi ? hi : v);
}

float fixed_point_to_float(U32 fx){
    int sign = (fx & 0x8000) ? -1 : 1;
    U32 magnitude = (fx & 0x7FFF);
    return sign * ((float)magnitude / SCALE_FACTOR);
}

U32 FX_convert(float x){
    float s = x * SCALE_FACTOR;
    int16_t f = (s >= 0) ? (int16_t)(s + 0.5f) : (int16_t)(s - 0.5f);
    if (f > 32767) f = 32767;
    else if (f < -32768) f = -32768;
    return (U32)(f & 0xFFFF);
}

// ---- Text helpers ----
static void draw_text(SDL_Renderer* ren, TTF_Font* font, const char* msg, int x, int y, SDL_Color col){
    SDL_Surface *surf = TTF_RenderUTF8_Blended(font, msg, col);
    if(!surf) return;
    SDL_Texture *tex = SDL_CreateTextureFromSurface(ren, surf);
    if(tex){
        SDL_Rect r = { x, y, surf->w, surf->h };
        SDL_RenderCopy(ren, tex, NULL, &r);
        SDL_DestroyTexture(tex);
    }
    SDL_FreeSurface(surf);
}

static void draw_text_center(SDL_Renderer* ren, TTF_Font* font, const char* msg, int y, SDL_Color col){
    int w=0, h=0;
    if (TTF_SizeUTF8(font, msg, &w, &h) != 0) return;
    int x = (WIDTH - w)/2;
    draw_text(ren, font, msg, x, y, col);
}
// -----------------------

// ---- Vietnamese class names for 0..4 ----
static const char* VN_LABELS[5] = {
    "Bình thường",                 // 0 = N
    "Ngoại tâm thu trên thất",     // 1 = S
    "Ngoại tâm thu thất",          // 2 = V
    "Nhịp hợp nhất",               // 3 = F
    "Không xác định"               // 4 = Q/Other
};
// -----------------------------------------

int main(int argc, char** argv){
	const int PRED_SHOW_AT_SAMPLES = (SEG_LEN * 3) / 4; 

    // CLI paths (optional)
    const char *signals_path = (argc >= 2) ? argv[1] : "signals.txt";
    const char *labels_path  = (argc >= 3) ? argv[2] : "labels.txt";
    const char *font_path    = (argc >= 4) ? argv[3] : "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf";

    // ===== FPGA init =====
    unsigned char* membase;
    if (cgra_open() == 0) exit(1);
    cgra.dma_ctrl = CGRA_info.dma_mmap;
    membase = (unsigned char*)CGRA_info.ddr_mmap;
    printf("membase: %llx\n", (U64)membase);

    FILE *CRAM_file = fopen("CRAM_File.txt", "r");
    if(!CRAM_file){ perror("CRAM_File.txt"); return 1; }
    FILE *WRAM_file = fopen("WRAM_File.txt", "r");
    if(!WRAM_file){ perror("WRAM_File.txt"); return 1; }
    FILE *BRAM_file = fopen("BRAM_File.txt", "r");
    if(!BRAM_file){ perror("BRAM_File.txt"); return 1; }
    FILE *WRAM_2_file = fopen("WRAM_2_File.txt", "r");
    if(!WRAM_2_file){ perror("WRAM_2_File.txt"); return 1; }
    FILE *BRAM_2_file = fopen("BRAM_2_File.txt", "r");
    if(!BRAM_2_file){ perror("BRAM_2_File.txt"); return 1; }

    int i = 0;
    U32 value; float value_f;
    float weight_final[160], bias_final[5];
    U32 CRAM[42], WRAM[6096], BRAM[196];

    while (fscanf(CRAM_file, "%8x", &value) == 1) CRAM[i++] = value; fclose(CRAM_file);
    i=0; while (fscanf(WRAM_file, "%4x", &value) == 1) WRAM[i++] = value; fclose(WRAM_file);
    i=0; while (fscanf(BRAM_file, "%4x", &value) == 1) BRAM[i++] = value; fclose(BRAM_file);

    for(int j=0;j<42;j++)   *(CGRA_info.reg_mmap + CRAM_INPUT_BASE_PHYS + j) = CRAM[j];
    for(int j=0;j<6096;j++) *(CGRA_info.reg_mmap + WRAM_INPUT_BASE_PHYS + j) = WRAM[j];
    for(int j=0;j<196;j++)  *(CGRA_info.reg_mmap + BRAM_INPUT_BASE_PHYS + j) = BRAM[j];

    i=0; while (fscanf(WRAM_2_file, "%f", &value_f) == 1) weight_final[i++] = value_f; fclose(WRAM_2_file);
    i=0; while (fscanf(BRAM_2_file, "%f", &value_f) == 1) bias_final[i++]   = value_f; fclose(BRAM_2_file);

    // ===== Load dataset =====
    float* InModel = (float*)malloc(NumberOfPicture * d * SEG_LEN * sizeof(float));
    float tmp;
    FILE* Input = fopen(signals_path, "r");
    if(!Input){ perror("signals"); return 1; }
    for(int k=0;k<NumberOfPicture*d*SEG_LEN;k++){
        if (fscanf(Input, "%f", &tmp)!=1){ fprintf(stderr,"signals: not enough floats\n"); return 1; }
        InModel[k]=tmp;
    }
    fclose(Input);

    float* Label = (float*)malloc(NumberOfPicture * sizeof(float));
    FILE* Output = fopen(labels_path, "r");
    if(!Output){ perror("labels"); free(InModel); return 1; }
    for(int k=0;k<NumberOfPicture;k++){
        if (fscanf(Output, "%f", &tmp)!=1){ fprintf(stderr,"labels: not enough\n"); return 1; }
        Label[k]=tmp;
    }
    fclose(Output);

    float* OutArray = (float*)malloc(NumberOfPicture * sizeof(float));
    float CNN_output[1280];
    float GlobalAveragePool1D[32];
    float out_Dense[5];
    float Image[d*SEG_LEN];
    U32 Pixel[340];
    uint16_t address[1280];
    struct timespec start_CNN,end_CNN;
    unsigned long long time_spent_CNN=0;

    for(int j=0;j<1280;j++){ int a=j/20; address[j]=(j+a*12)&0xFFFF; }

    // ===== SDL init =====
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER)!=0){ fprintf(stderr,"SDL_Init: %s\n", SDL_GetError()); return 1; }
    if (TTF_Init()!=0){ fprintf(stderr,"TTF_Init: %s\n", TTF_GetError()); return 1; }

    SDL_Window *winw = SDL_CreateWindow("FPGA ECG Viewer",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIDTH, HEIGHT, 0);
    if(!winw){ fprintf(stderr,"SDL_CreateWindow: %s\n", SDL_GetError()); return 1; }
    SDL_Renderer *ren = SDL_CreateRenderer(winw, -1, SDL_RENDERER_ACCELERATED);
    if(!ren){ fprintf(stderr,"SDL_CreateRenderer: %s\n", SDL_GetError()); return 1; }

    TTF_Font *font = TTF_OpenFont(font_path, 16);
    if(!font){ fprintf(stderr,"TTF_OpenFont: %s\n", TTF_GetError()); return 1; }

    // waveform ring buffer for visible window
    double fs = 360.0, view_seconds = 5.0;
    int win_len = (int)(fs*view_seconds); if(win_len<10) win_len=10;
    double *buf = (double*)calloc(win_len, sizeof(double));
    int buf_n=0, buf_head=0;
    long long total_samples=0;

    double slow_factor = 5.0;     
    int update_every = 10;       
    double ms_per_sample = 1000.0*slow_factor/fs, ms_accum=0.0;

    int running=1;
    int correct=0;
    SDL_Color black={0,0,0,255}, red={255,0,0,255};

    for(int iimg=0;iimg<NumberOfPicture && running;iimg++){
        int startIndex = iimg*d*SEG_LEN;
        for(int k=0;k<d*SEG_LEN;k++) Image[k]=InModel[startIndex+k];

        for(int k=0;k<340;k++) Pixel[k]= (k<SEG_LEN)? FX_convert(Image[k]) : FX_convert(0.0f);

        // Run FPGA
        clock_gettime(CLOCK_REALTIME, &start_CNN);
        for(int k=0;k<340;k++) *(CGRA_info.reg_mmap + LDM_INPUT_BASE_PHYS + address[k]) = Pixel[k];
        *(CGRA_info.reg_mmap + START_BASE) = 1;
        while(1){ if(*(CGRA_info.reg_mmap + DONE_BASE_PHYS)==1) break; }

        for(int j=0;j<1280;j++)
            CNN_output[j] = fixed_point_to_float(*(CGRA_info.reg_mmap + LDM_OUTPUT_BASE_PHYS + address[j]));

        for(int j=0;j<32;j++){
            float avg=0; for(int k=0;k<40;k++) avg += CNN_output[40*j+k];
            GlobalAveragePool1D[j]=avg/40.0f;
        }
        for(int j=0;j<5;j++){
            float s=0; for(int k=0;k<32;k++) s += GlobalAveragePool1D[k]*weight_final[k*5 + j];
            out_Dense[j]=s+bias_final[j];
        }
        int pred=0; float best=out_Dense[0];
        for(int j=1;j<5;j++) if(out_Dense[j]>best){best=out_Dense[j]; pred=j;}
        OutArray[iimg]=(float)pred;

        clock_gettime(CLOCK_REALTIME, &end_CNN);
        time_spent_CNN += BILLION*(end_CNN.tv_sec - start_CNN.tv_sec) + (end_CNN.tv_nsec - start_CNN.tv_nsec);

        int gt=(int)Label[iimg];
        if (gt==pred) correct++;
        double acc = 100.0 * (double)correct / (double)(iimg+1);

        long long box_start = total_samples;
        long long box_end   = total_samples + SEG_LEN;
		
		for (int s = 0; s < SEG_LEN && running; s++) {
			double v = Image[s];
			if (buf_n < win_len) { 
				buf[buf_n++] = v; 
			} else { 
				buf[buf_head] = v; 
				buf_head = (buf_head + 1) % win_len; 
			}
			total_samples++;

			if (s % update_every == 0 || s == SEG_LEN-1) {
				SDL_Event e; 
				while (SDL_PollEvent(&e)) if (e.type == SDL_QUIT) running = 0;
				if (!running) break;

				// ==== y-range ====
				double ymin = buf[0], ymax = buf[0];
				for (int ii = 1; ii < buf_n; ++ii) {
					double vv = buf[(buf_head + ii) % buf_n];
					if (vv < ymin) ymin = vv;
					if (vv > ymax) ymax = vv;
				}
				if (fabs(ymax - ymin) < 1e-9) { ymin -= 0.1; ymax += 0.1; }

				// ==== clear ====
				SDL_SetRenderDrawColor(ren, 255,255,255,255);
				SDL_RenderClear(ren);

				// TOP: centered Accuracy
				char acc_str[128];
				snprintf(acc_str, sizeof(acc_str),
						 "Accuracy: %.2f%%  (%d/%d)", acc, correct, iimg+1);
				draw_text_center(ren, font, acc_str, 4, black);

				// BOTTOM: GT (VN)
				char gt_str[128];
				const char* gt_name = (gt >= 0 && gt < 5)? VN_LABELS[gt] : "N/A";
				snprintf(gt_str, sizeof(gt_str), "GT: %d (%s)", gt, gt_name);
				draw_text(ren, font, gt_str, 8, HEIGHT - BOT_BAR + 4, black);

				// waveform
				SDL_Rect plot_rect = {0, TOP_BAR, WIDTH, PLOT_H};
				SDL_SetRenderDrawColor(ren, 0,0,0,255);
				for (int ii = 1; ii < buf_n; ++ii) {
					double x0 = (double)(ii-1)/(double)win_len;
					double x1 = (double)ii/(double)win_len;
					double v0 = buf[(buf_head + ii - 1) % buf_n];
					double v1 = buf[(buf_head + ii) % buf_n];
					int X0 = (int)(x0 * (WIDTH-1));
					int X1 = (int)(x1 * (WIDTH-1));
					int Y0 = plot_rect.y + (int)((1.0 - (v0 - ymin) / (ymax - ymin)) * (plot_rect.h - 1));
					int Y1 = plot_rect.y + (int)((1.0 - (v1 - ymin) / (ymax - ymin)) * (plot_rect.h - 1));
					SDL_RenderDrawLine(ren, X0, Y0, X1, Y1);
				}

				// red box for current beat
				long long vis_start = total_samples - buf_n;
				long long vis_end   = total_samples;
				long long is0 = (box_start > vis_start) ? box_start : vis_start;
				long long is1 = (box_end   < vis_end  ) ? box_end   : vis_end;
				if (is1 > is0) {
					int b0 = (int)(is0 - vis_start);
					int b1 = (int)(is1 - vis_start);
					int X0 = (int)clampd((double)b0 / (double)win_len * (WIDTH - 1), 0, WIDTH - 1);
					int X1 = (int)clampd((double)b1 / (double)win_len * (WIDTH - 1), 0, WIDTH - 1);
					if (X1 <= X0) X1 = X0 + 1;

					SDL_Rect r = (SDL_Rect){ X0, plot_rect.y, X1 - X0, plot_rect.h };
					SDL_SetRenderDrawColor(ren, 255, 0, 0, 255);
					SDL_RenderDrawRect(ren, &r);

					if (s >= PRED_SHOW_AT_SAMPLES) {
						const char* pred_name = (pred >= 0 && pred < 5) ? VN_LABELS[pred] : "N/A";
						char pred_str[160];
						snprintf(pred_str, sizeof(pred_str), "Pred: %d (%s)", pred, pred_name);

						int tw = 0, th = 0;
						TTF_SizeUTF8(font, pred_str, &tw, &th);
						int x_text = X0 + (X1 - X0)/2 - tw/2;
						if (x_text < 2) x_text = 2;
						if (x_text > WIDTH - tw - 2) x_text = WIDTH - tw - 2;
						draw_text(ren, font, pred_str, x_text, plot_rect.y + 4, red);
					}
				}
				SDL_RenderPresent(ren);

				// pacing
				ms_accum += ms_per_sample * (double)update_every;
				if (ms_accum >= 1.0) {
					Uint32 ms = (Uint32)ms_accum;
					SDL_Delay(ms);
					ms_accum -= ms;
				}
			} 
		} 
	}

	
    double final_acc = 100.0 * (double)correct / (double)NumberOfPicture;
    printf("Accuracy of Model = %.2f%%\n", final_acc);
    printf("Execution time (s): %f\n", (double)time_spent_CNN/BILLION);

    // Wait for close
    int wait=1; while(wait){ SDL_Event e; while(SDL_PollEvent(&e)) if(e.type==SDL_QUIT) wait=0; SDL_Delay(10); }

    free(InModel); free(Label); free(OutArray); free(buf);
    TTF_CloseFont(font);
    SDL_DestroyRenderer(ren); SDL_DestroyWindow(winw);
    TTF_Quit(); SDL_Quit();
    return 0;
}

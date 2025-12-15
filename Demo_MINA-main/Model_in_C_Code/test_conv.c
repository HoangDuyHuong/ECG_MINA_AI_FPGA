#include <stdio.h>
#include <stdint.h>
#include <math.h>

#define CTX_BITS       32
#define PAD_BITS       2
#define N_BITS         5
#define Y_BITS         3
#define K_BITS         5
#define J_BITS         3
#define ALU_CFG_BITS   3
#define STRIDE_BITS    1
#define S_LDM_BITS     2
#define D_LDM_BITS     2
#define SA_LDM_BITS    6

int weight_addr = 0;
int bias_addr = 0;
int ctx_addr = 0;

#define FRACTIONAL_BITS 6
#define SCALE_FACTOR (1 << FRACTIONAL_BITS)

uint32_t concatenate_to_32bit(int pad, int n, int y, int k, int j, int alu_cfg, int stride, int s_ldm, int d_ldm, int sa_ldm) {
    uint32_t result = 0;
    pad     &= (1 << PAD_BITS) - 1;
    n       &= (1 << N_BITS) - 1;
    y       &= (1 << Y_BITS) - 1;
    k       &= (1 << K_BITS) - 1;
    j       &= (1 << J_BITS) - 1;
    alu_cfg &= (1 << ALU_CFG_BITS) - 1;
    stride  &= (1 << STRIDE_BITS) - 1;
    s_ldm   &= (1 << S_LDM_BITS) - 1;
    d_ldm   &= (1 << D_LDM_BITS) - 1;
    sa_ldm  &= (1 << SA_LDM_BITS) - 1;

    result |= (pad     << (CTX_BITS - PAD_BITS));
    result |= (n       << (CTX_BITS - PAD_BITS - N_BITS));
    result |= (y       << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS));
    result |= (k       << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS));
    result |= (j       << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS));
    result |= (alu_cfg << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS));
    result |= (stride  << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS));
    result |= (s_ldm   << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS - S_LDM_BITS));
    result |= (d_ldm   << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS - S_LDM_BITS - D_LDM_BITS));
    result |= (sa_ldm  << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS - S_LDM_BITS - D_LDM_BITS - SA_LDM_BITS));

    return result;
}

int16_t FX_convert(float input) {
    float scaled_value = input * SCALE_FACTOR;
    int16_t fixed_value;
    if (scaled_value >= 0) {
        fixed_value = (int16_t)(scaled_value + 0.5f);
    } else {
        fixed_value = (int16_t)(scaled_value - 0.5f);
    }

    if (fixed_value > 32767) {
        fixed_value = 32767;
    } else if (fixed_value < -32768) {
        fixed_value = -32768;
    }

    return fixed_value;
}

void write_weight_to_file(float data[], int length, FILE* weight_file) {
    for (int i = 0; i < length; i++) {
        int data_16bit = FX_convert(data[i]) & 0xFFFF;
        fprintf(weight_file, "%04x_%04x\n", weight_addr++, data_16bit);
    }
}

void write_bias_to_file(float data[], int length, FILE* bias_file) {
    for (int i = 0; i < length; i++) {
        int data_16bit = FX_convert(data[i]) & 0xFFFF;
        fprintf(bias_file, "%04x_%04x\n", bias_addr++, data_16bit);
    }
}

void write_context_to_file(uint32_t data[], int length, FILE* context_file) {
    for (int i = 0; i < length; i++) {
        fprintf(context_file, "%04x_%08x\n", ctx_addr++, data[i]);
    }
}

// Function to write data to file in "address_data" format
void write_to_file(const char* filename, float data[], int length) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        printf("Error: Unable to open file %s for writing.\n", filename);
        return;
    }

    for (int i = 0; i < length; i++) {
        int fixed_point_value = FX_convert(data[i]);
        // Ensure 16-bit representation of the address and data
	
        int address = (i) & 0xFFFF; // Mask to 16-bit address
		// printf("address = %d\n",address);
        int data_16bit = fixed_point_value & 0xFFFF; // Mask to 16-bit data
        
        fprintf(file, "%04x_%04x\n", address, data_16bit);
    }

    fclose(file);
}

void write_to_file2(const char* filename, float data[], int length) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        printf("Error: Unable to open file %s for writing.\n", filename);
        return;
    }

    for (int i = 0; i < length; i++) {
        int fixed_point_value = FX_convert(data[i]);
        // Ensure 16-bit representation of the address and data
		int a = i/20;
        int address = (i + a*12) & 0xFFFF; // Mask to 16-bit address
		// printf("address = %d\n",address);
        int data_16bit = fixed_point_value & 0xFFFF; // Mask to 16-bit data
        
        fprintf(file, "%04x_%04x\n", address, data_16bit);
    }

    fclose(file);
}

float fixedpoint_converter(float value) {
    if(value >= 512){
        value = value - 512;    
    }
    float scalingFactor = 64.0f;
    return round(value * scalingFactor) / scalingFactor; 
}

void Padding_Conv1D_0(float input_Pad_Conv[320], float output_Pad_Conv[325]){
	
	write_to_file2("LDM_File.txt", input_Pad_Conv, 340);
    for (int c = 0; c < 1; c++){
        for (int n = 0; n < 325; n++){
            if (n < 2 || n >= 322) output_Pad_Conv[324 * c + n]=0; 
            else output_Pad_Conv[324 * c + n] = input_Pad_Conv[320 * c + n - 2];
        }
    }
	output_Pad_Conv[324] = 0;
}

void Conv1D_0(float Input_Conv[325], float Output_Conv[1280], float bias[8], float kernel[56], FILE* weight_file, FILE* bias_file, FILE* context_file){
    for (int i = 0; i < 324; i++) {
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
    for (int i = 0; i < 56; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }

    int stride = 2;
    int n, y, k, j;
	Input_Conv[324] = 0;
    printf("Input_Conv[324] = %f\n",Input_Conv[324]);
    for (n = 0; n < 8; n++){
        for (y = 0; y < 160; y++){
            float s = 0;
            for (k = 0; k < 1; k++){
                for (j = 0; j < 7; j++){
                    s += (kernel[1*7*n+7*k+j]) * (Input_Conv[324*k+j+y*stride]);
                    s = fixedpoint_converter(s);
					if((y%20)==19){
						if((((324*k+j+y*stride)%324)>=2&&((324*k+j+y*stride)%324)<322))
							printf("PE = %d, W_addr = %d, from PE = %d, Read LDM_addr = %d (%d), Data = %f(324*k+j+y*stride =%d), kernel = %f, s = %f\n",y%20, 1*7*n+7*k+j,(324*k+j+y*stride-2*(k+1))%20, (324*k+j+y*stride-2*(k+1))/20,(324*k+j+y*stride-2*(k+1)),Input_Conv[324*k+j+y*stride], 324*k+j+y*stride,kernel[1*7*n+7*k+j], fixedpoint_converter(s));
						else 
						{printf("PE = %d, W_addr = %d, from PE = %d, Read Pad_addr = %d, Data = %f(324*k+j+y*stride =%d), kernel = %f, s = %f\n",y%20,1*7*n+7*k+j,(324*k+j+y*stride-2*(k+1)+20)%20,324*k+j+y*stride,Input_Conv[324*k+j+y*stride], 324*k+j+y*stride, kernel[1*7*n+7*k+j], s);
						printf("Input_Conv[324] = %f\n",Input_Conv[324]);
						}
					}
                }
            }
            Output_Conv[160*n+y] = s + bias[n];
			if((y%20)==19){
				printf("PE = %d, bias_addr = %d, Store LDM_addr = %d, s = %f, Output_Conv[%d] = %f\n\n\n",(160*n+y)%20,n,(160*n+y)/20, s, 160*n+y, fixedpoint_converter(Output_Conv[160*n+y]));
			}
        }
    }

    for (int i = 0; i < 1280; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
    write_to_file("Output_Conv.txt", Output_Conv, 1280);
    write_bias_to_file(bias, 8, bias_file);
    write_weight_to_file(kernel, 56, weight_file);
    int pad_ctx = 2, n_ctx = 7, y_ctx = 7, k_ctx = 0, j_ctx = 6, alu_cfg_ctx = 5, stride_ctx = 1,s_ldm_ctx = 0, d_ldm_ctx = 3, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
    write_context_to_file(&result, 1, context_file);
}

void Conv1D_1(float Input_Conv[1280], float Output_Conv[320], float bias[2], float kernel[16], FILE* weight_file, FILE* bias_file, FILE* context_file) {
    int stride = 1;
    int n, y, k, j;

    // Convert inputs to fixed-point format
    for (int i = 0; i < 1280; i++) {
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
    }

    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }

    for (int i = 0; i < 16; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	write_to_file2("LDM_File.txt", Input_Conv, 1280);
    // Convolution Operation
    for (n = 0; n < 2; n++) {
        for (y = 0; y < 160; y++) {
            float s = 0;
            for (k = 0; k < 8; k++) {
                for (j = 0; j < 1; j++) {
                    s += (kernel[8 * 1 * n + 1 * k + j]) * (Input_Conv[160 * k + j + y * stride]);
                }
            }
            Output_Conv[160 * n + y] = s + bias[n];
        }
    }

    // Convert output to fixed-point format
    for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	write_to_file("Output_Conv.txt", Output_Conv, 320);
    // Writing to files with file pointers
    write_bias_to_file(bias, 2, bias_file);
    write_weight_to_file(kernel, 16, weight_file);

    // Write context information
    int pad_ctx = 0, n_ctx = 1, y_ctx = 7, k_ctx = 7, j_ctx = 0, alu_cfg_ctx = 1;
    int stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 3, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
    write_context_to_file(&result, 1, context_file);
}

void Padding_Conv1D_3(float input_Pad_Conv[320], float output_Pad_Conv[324]) {
	
	write_to_file2("LDM_File.txt", input_Pad_Conv, 320);
    for (int c = 0; c < 2; c++) {
        for (int n = 0; n < 162; n++) {
            if (n < 1 || n >= 161) 
                output_Pad_Conv[162 * c + n] = 0;
            else 
                output_Pad_Conv[162 * c + n] = input_Pad_Conv[160 * c + n - 1];
        }
    }
}

void Conv1D_3(float Input_Conv[324], float Output_Conv[320], float bias[2], float kernel[12], FILE* weight_file, FILE* bias_file, FILE* context_file) {
    int stride = 1;

    // Convert inputs to fixed-point format
    for (int i = 0; i < 324; i++) {
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
    }

    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }

    for (int i = 0; i < 12; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }

    // Convolution Operation
    for (int n = 0; n < 2; n++) {
        for (int y = 0; y < 160; y++) {
            float s = 0;
            for (int k = 0; k < 2; k++) {
                for (int j = 0; j < 3; j++) {
                    s += kernel[2 * 3 * n + 3 * k + j] * Input_Conv[162 * k + j + y * stride];
                }
            }
            Output_Conv[160 * n + y] = s + bias[n];
        }
    }

    // Convert output to fixed-point format
    for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_to_file("Output_Conv.txt", Output_Conv, 320);
    // Write to files using file pointers
    write_bias_to_file(bias, 2, bias_file);
    write_weight_to_file(kernel, 12, weight_file);

    // Context configuration and writing to file
    int pad_ctx = 1, n_ctx = 1, y_ctx = 7, k_ctx = 1, j_ctx = 2, alu_cfg_ctx = 5;
    int stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 3, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
    write_context_to_file(&result, 1, context_file);
}

void Padding_Conv1D_4(float input_Pad_Conv[320], float output_Pad_Conv[328]) {
	
	write_to_file2("LDM_File.txt", input_Pad_Conv, 320);
    for (int c = 0; c < 2; c++) {
        for (int n = 0; n < 164; n++) {
            if (n < 2 || n >= 162) 
                output_Pad_Conv[164 * c + n] = 0;
            else 
                output_Pad_Conv[164 * c + n] = input_Pad_Conv[160 * c + n - 2];
        }
    }
}

void Conv1D_4(float Input_Conv[328], float Output_Conv[320], float bias[2], float kernel[20], FILE* weight_file, FILE* bias_file, FILE* context_file) {
    int stride = 1;

    // Convert inputs to fixed-point format
    for (int i = 0; i < 328; i++) {
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
    }

    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }

    for (int i = 0; i < 20; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }

    // Convolution Operation
    for (int n = 0; n < 2; n++) {
        for (int y = 0; y < 160; y++) {
            float s = 0;
            for (int k = 0; k < 2; k++) {
                for (int j = 0; j < 5; j++) {
                    s += kernel[2 * 5 * n + 5 * k + j] * Input_Conv[164 * k + j + y * stride];
                }
            }
            Output_Conv[160 * n + y] = s + bias[n];
        }
    }

    // Convert output to fixed-point format
    for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	write_to_file("Output_Conv.txt", Output_Conv, 320);
    // Writing to files using file pointers
    write_bias_to_file(bias, 2, bias_file);
    write_weight_to_file(kernel, 20, weight_file);

    // Context configuration and writing to file
    int pad_ctx = 2, n_ctx = 1, y_ctx = 7, k_ctx = 1, j_ctx = 4, alu_cfg_ctx = 5;
    int stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 3, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
    write_context_to_file(&result, 1, context_file);
}

void Padding_Conv1D_5(float input_Pad_Conv[320], float output_Pad_Conv[332]) {
    // Optionally write input to a file
    write_to_file2("LDM_File.txt", input_Pad_Conv, 320);

    for (int c = 0; c < 2; c++) {
        for (int n = 0; n < 166; n++) {
            if (n < 3 || n >= 163) 
                output_Pad_Conv[166 * c + n] = 0;
            else 
                output_Pad_Conv[166 * c + n] = input_Pad_Conv[160 * c + n - 3];
        }
    }
}

void Conv1D_5(float Input_Conv[332], float Output_Conv[320], float bias[2], float kernel[28], FILE* weight_file, FILE* bias_file, FILE* context_file) {
    int stride = 1;

    // Convert inputs to fixed-point format
    for (int i = 0; i < 332; i++) {
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
    }

    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }

    for (int i = 0; i < 28; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }

    // Convolution Operation
    for (int n = 0; n < 2; n++) {
        for (int y = 0; y < 160; y++) {
            float s = 0;
            for (int k = 0; k < 2; k++) {
                for (int j = 0; j < 7; j++) {
                    s += kernel[2 * 7 * n + 7 * k + j] * Input_Conv[166 * k + j + y * stride];
                }
            }
            Output_Conv[160 * n + y] = s + bias[n];
        }
    }

    // Convert output to fixed-point format
    for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_to_file("Output_Conv.txt", Output_Conv, 320);

    // Writing to files using file pointers
    write_bias_to_file(bias, 2, bias_file);
    write_weight_to_file(kernel, 28, weight_file);

    // Context configuration and writing to file
    int pad_ctx = 3, n_ctx = 1, y_ctx = 7, k_ctx = 1, j_ctx = 6, alu_cfg_ctx = 5;
    int stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 3, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
    write_context_to_file(&result, 1, context_file);
}

void Padding_Conv1D_11(float input_Pad_Conv[1280], float output_Pad_Conv[1297]) {
	
	 write_to_file2("LDM_File.txt", input_Pad_Conv, 1280);


    for (int c = 0; c < 8; c++) {
        for (int n = 0; n < 162; n++) {
            if (n < 1 || n >= 161) 
                output_Pad_Conv[162 * c + n] = 0;
            else 
                output_Pad_Conv[162 * c + n] = input_Pad_Conv[160 * c + n - 1];
        }
    }
	output_Pad_Conv[1296] = 0;
}

void Conv1D_11(float Input_Conv[1297], float Output_Conv[1280], float bias[16], float kernel[640], FILE* weight_file, FILE* bias_file, FILE* context_file) {
    int stride = 2;

    // Convert inputs to fixed-point format
    for (int i = 0; i < 1296; i++) {
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
    }

    for (int i = 0; i < 16; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }

    for (int i = 0; i < 640; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }

    // Convolution Operation
    for (int n = 0; n < 16; n++) {
        for (int y = 0; y < 80; y++) {
            float s = 0;
            for (int k = 0; k < 8; k++) {
                for (int j = 0; j < 5; j++) {
                    s += kernel[8 * 5 * n + 5 * k + j] * Input_Conv[162 * k + j + y * stride];
               if((y==79)&(n==0)){
						if((((162*k+j+y*stride)%162)>=1&&((162*k+j+y*stride)%162)<161))
							printf("PE = %d, W_addr = %d, from PE = %d, Read LDM_addr = %d (%d), Data = %f, kernel = %f, s = %f\n",y%20, 8*5*n+5*k+j,(162*k+j+y*stride-(1+2*k))%20, (162*k+j+y*stride-(1+2*k))/20,(162*k+j+y*stride-(1+2*k)),Input_Conv[162*k+j+y*stride], kernel[8*5*n+5*k+j], fixedpoint_converter(s));
						else 
							printf("PE = %d, W_addr = %d, from PE = %d, Read Pad_addr = %d, Data = %f, kernel = %f, s = %f\n",y%20,8*5*n+5*k+j,(162*k+j+y*stride-(1+2*k)+20)%20,162*k+j+y*stride,Input_Conv[162*k+j+y*stride], kernel[8*5*n+5*k+j], s);
					}
                }
            }
            Output_Conv[80 * n + y] = s + bias[n];
			if((y==79)&(n==0))
				printf("PE = %d, bias_addr = %d, Store LDM_addr = %d, s = %f, Output_Conv[%d] = %f\n\n\n",(80*n+y)%20,n,(80*n+y)/20, s, 80*n+y, fixedpoint_converter(Output_Conv[80*n+y]));
        }
    }

    // Convert output to fixed-point format
    for (int i = 0; i < 1280; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_to_file("Output_Conv.txt", Output_Conv, 1280);

    // Writing to files using file pointers
    write_bias_to_file(bias, 16, bias_file);
    write_weight_to_file(kernel, 640, weight_file);

    // Context configuration and writing to file
    int pad_ctx = 1, n_ctx = 15, y_ctx = 3, k_ctx = 7, j_ctx = 4, alu_cfg_ctx = 5;
    int stride_ctx = 1, s_ldm_ctx = 0, d_ldm_ctx = 3, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
    write_context_to_file(&result, 1, context_file);
}

void Padding_Conv1D_22(float input_Pad_Conv[1280], float output_Pad_Conv[1281]) {
	 write_to_file2("LDM_File.txt", input_Pad_Conv, 1280);
    for (int c = 0; c < 16; c++) {
        for (int n = 0; n < 80; n++) {
            if (n >= 80) 
                output_Pad_Conv[80 * c + n] = 0;
            else 
                output_Pad_Conv[80 * c + n] = input_Pad_Conv[80 * c + n];
        }
    }
	output_Pad_Conv[1280] = 0;
}

void Conv1D_22(float Input_Conv[1281], float Output_Conv[1280], float bias[32], float kernel[1536], FILE* weight_file, FILE* bias_file, FILE* context_file) {
    int stride = 2;

    // Convert inputs to fixed-point format
    for (int i = 0; i < 1280; i++) {
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
    }

    for (int i = 0; i < 32; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }

    for (int i = 0; i < 1536; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }

    // Convolution Operation
    for (int n = 0; n < 32; n++) {
        for (int y = 0; y < 40; y++) {
            float s = 0;
            for (int k = 0; k < 16; k++) {
                for (int j = 0; j < 3; j++) {
                    s += kernel[16 * 3 * n + 3 * k + j] * Input_Conv[80 * k + j + y * stride];
					
					 if((y%20)==3){
							printf("PE = %d, W_addr = %d, from PE = %d, Read LDM_addr = %d (%d), Data = %f, kernel = %f, s = %f\n",y%20, 16 * 3 * n + 3 * k + j,(80 * k + j + y * stride)%20, (80 * k + j + y * stride)/20,(80 * k + j + y * stride),Input_Conv[80 * k + j + y * stride], kernel[16 * 3 * n + 3 * k + j], fixedpoint_converter(s));
					}
                }
            }
            Output_Conv[40 * n + y] = s + bias[n];
			if((y%20)==3)
			printf("PE = %d, bias_addr = %d, Store LDM_addr = %d, s = %f, Output_Conv[%d] = %f\n\n\n",(40 * n + y)%20,n,(40 * n + y)/20, s, 40 * n + y, fixedpoint_converter(Output_Conv[40 * n + y]));
        }
    }

    // Convert output to fixed-point format
    for (int i = 0; i < 1280; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	write_to_file("Output_Conv.txt", Output_Conv, 1280);
    // Writing to files using file pointers
    write_bias_to_file(bias, 32, bias_file);
    write_weight_to_file(kernel, 1536, weight_file);

    // Context configuration and writing to file
    int pad_ctx = 0, n_ctx = 31, y_ctx = 1, k_ctx = 15, j_ctx = 2, alu_cfg_ctx = 5;
    int stride_ctx = 1, s_ldm_ctx = 0, d_ldm_ctx = 3, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
    write_context_to_file(&result, 1, context_file);
}

int main() {
    FILE *weight_file = fopen("WRAM_File.txt", "w");
    FILE *bias_file = fopen("BRAM_File.txt", "w");
    FILE *context_file = fopen("CRAM_File.txt", "w");

    if (!weight_file || !bias_file || !context_file) {
        printf("Error opening one or more files.\n");
        return 1;
    }

    float bias[8];
    float kernel[56];
    float input_Pad_Conv[320];
    float output_Pad_Conv[325];
    float Input_Conv[325];
    float Output_Conv[1280];

    for (int i = 0; i < 320; i++) {
        input_Pad_Conv[i] = 0.015625 * (i + 1);
    }

    for (int i = 0; i < 8; i++) {
        bias[i] = (i + 1);
    }
    
    for (int i = 0; i < 56; i++) {
        kernel[i] = 0.0625 + 0.015625 * (i + 1);
    }
    
    Padding_Conv1D_0(input_Pad_Conv, output_Pad_Conv);
    Conv1D_0(output_Pad_Conv, Output_Conv, bias, kernel, weight_file, bias_file, context_file);
	
/////////////////////////////////////////////////////////////////////////////////////

    // float bias[2];
    // float kernel[16];
    // float input_Conv[1280];
    // float Output_Conv[320];

    // for (int i = 0; i < 1280; i++) {
        // input_Conv[i] = 0.015625 * (i);
    // }

    // for (int i = 0; i < 2; i++) {
        // bias[i] = (i + 1);
    // }
    
    // for (int i = 0; i < 16; i++) {
        // kernel[i] = 1;
    // }
    
    // Conv1D_1(input_Conv, Output_Conv, bias, kernel, weight_file, bias_file, context_file);	

/////////////////////////////////////////////////////////////////////////////////////

    // float bias[2];
    // float kernel[12];
    // float input_Pad_Conv[320];
    // float output_Pad_Conv[324];
    // float Input_Conv[324];
    // float Output_Conv[320];

    // for (int i = 0; i < 320; i++) {
        // input_Pad_Conv[i] = 0.015625 * (i + 1);
    // }

    // for (int i = 0; i < 2; i++) {
        // bias[i] = (i + 1);
    // }
    
    // for (int i = 0; i < 12; i++) {
        // kernel[i] = 1;
    // }
    
    // Padding_Conv1D_3(input_Pad_Conv, output_Pad_Conv);
    // Conv1D_3(output_Pad_Conv, Output_Conv, bias, kernel, weight_file, bias_file, context_file);
	
/////////////////////////////////////////////////////////////////////////////////////

    // float bias[2];
    // float kernel[20];
    // float input_Pad_Conv[320];
    // float output_Pad_Conv[332];
    // float Input_Conv[332];
    // float Output_Conv[320];

    // for (int i = 0; i < 320; i++) {
        // input_Pad_Conv[i] = 0.015625 * (i + 1);
    // }

    // for (int i = 0; i < 2; i++) {
        // bias[i] = (i + 1);
    // }
    
    // for (int i = 0; i < 28; i++) {
        // kernel[i] = 1;
    // }
    
    // Padding_Conv1D_4(input_Pad_Conv, output_Pad_Conv);
    // Conv1D_4(output_Pad_Conv, Output_Conv, bias, kernel, weight_file, bias_file, context_file);

/////////////////////////////////////////////////////////////////////////////////////

    // float bias[2];
    // float kernel[28];
    // float input_Pad_Conv[320];
    // float output_Pad_Conv[332];
    // float Input_Conv[332];
    // float Output_Conv[320];

    // for (int i = 0; i < 320; i++) {
        // input_Pad_Conv[i] = 0.015625 * (i + 1);
    // }

    // for (int i = 0; i < 2; i++) {
        // bias[i] = (i + 1);
    // }
    
    // for (int i = 0; i < 20; i++) {
        // kernel[i] = 1;
    // }
    
    // Padding_Conv1D_5(input_Pad_Conv, output_Pad_Conv);
    // Conv1D_5(output_Pad_Conv, Output_Conv, bias, kernel, weight_file, bias_file, context_file);

/////////////////////////////////////////////////////////////////////////////////////

    // float bias[16];
    // float kernel[640];
    // float input_Pad_Conv[1280];
    // float output_Pad_Conv[1297];
    // float Input_Conv[1297];
    // float Output_Conv[1280];

    // for (int i = 0; i < 1280; i++) {
        // input_Pad_Conv[i] = 0.015625*(1280-i);
    // }

    // for (int i = 0; i < 16; i++) {
        // bias[i] = 1;
    // }
    
    // for (int i = 0; i < 640; i++) {
        // kernel[i] = 1;
    // }
    
    // Padding_Conv1D_11(input_Pad_Conv, output_Pad_Conv);
    // Conv1D_11(output_Pad_Conv, Output_Conv, bias, kernel, weight_file, bias_file, context_file);

/////////////////////////////////////////////////////////////////////////////////////

    // float bias[32];
    // float kernel[1536];
    // float input_Pad_Conv[1280];
    // float output_Pad_Conv[1281];
    // float Input_Conv[1281];
    // float Output_Conv[1280];

    // for (int i = 0; i < 1280; i++) {
        // input_Pad_Conv[i] = 0.015625*(1280-i);
    // }

    // for (int i = 0; i < 32; i++) {
        // bias[i] = 1;
    // }
    
    // for (int i = 0; i < 1536; i++) {
        // kernel[i] = 1;
    // }
    
    // Padding_Conv1D_22(input_Pad_Conv, output_Pad_Conv);
    // Conv1D_22(output_Pad_Conv, Output_Conv, bias, kernel, weight_file, bias_file, context_file);
	
    fclose(weight_file);
    fclose(bias_file);
    fclose(context_file);

    return 0;
}

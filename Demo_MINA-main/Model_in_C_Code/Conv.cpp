#include <cmath>  // Include cmath for the round function
#include <cstdio>
#include <stdio.h>
#include <math.h>
#include <stdint.h>

// Define bit lengths as macros
#define CTX_BITS       32  // Total bits in the final result
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

#define NUM_VALUES 1280
#define FRACTIONAL_BITS 6
#define SCALE_FACTOR (1 << FRACTIONAL_BITS)

int weight_addr = 0;
int bias_addr = 0;
int ctx_addr = 0;

FILE *weight_file = fopen("WRAM_File.txt", "w");
FILE *bias_file = fopen("BRAM_File.txt", "w");
FILE *context_file = fopen("CRAM_File.txt", "w");
FILE *file1 = fopen("WRAM_2_File.txt", "w");	
FILE *file2 = fopen("BRAM_2_File.txt", "w");
// Function to concatenate inputs into a 32-bit integer
uint32_t concatenate_to_32bit(int pad, int n, int y, int k, int j, int alu_cfg, int stride, int s_ldm, int d_ldm, int sa_ldm) {
    uint32_t result = 0;

    // Ensure inputs are within their respective bit limits
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

    // Concatenate the inputs into a single 32-bit integer
    result |= (pad     << (CTX_BITS - PAD_BITS));                                 // Pad bits
    result |= (n       << (CTX_BITS - PAD_BITS - N_BITS));                        // N bits
    result |= (y       << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS));               // Y bits
    result |= (k       << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS));      // K bits
    result |= (j       << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS));  // J bits
    result |= (alu_cfg << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS));  // ALU CFG bits
    result |= (stride  << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS));  // Stride bits
    result |= (s_ldm   << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS - S_LDM_BITS));  // S_LDM bits
    result |= (d_ldm   << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS - S_LDM_BITS - D_LDM_BITS));  // D_LDM bit
    result |= (sa_ldm  << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS - S_LDM_BITS - D_LDM_BITS - SA_LDM_BITS));  // SA_LDM bits

    return result;
}

// Define the scale factor for 6 fractional bits
#define FRACTIONAL_BITS 6
#define SCALE_FACTOR (1 << FRACTIONAL_BITS)

// Function to convert float to 16-bit fixed-point (1 sign bit, 9 integer bits, 6 fractional bits)
int16_t FX_convert(float input) {
    // Multiply the input by the scale factor
    float scaled_value = input * SCALE_FACTOR;

    // Proper rounding towards zero for negative numbers
    int16_t fixed_value;
    if (scaled_value >= 0) {
        fixed_value = (int16_t)(scaled_value + 0.5f);  // Round up for positive values
    } else {
        fixed_value = (int16_t)(scaled_value - 0.5f);  // Round down for negative values
    }

    // Handle overflow and underflow cases explicitly within 16-bit range
    if (fixed_value > 32767) {
        fixed_value = 32767;
    } else if (fixed_value < -32768) {
        fixed_value = -32768;
    }

    // Return the fixed-point value
    return fixed_value;
}

// Function to write data to file in "address_data" format
void write_weight_to_file(float data[], int length) {
    
    for (int i = 0; i < length; i++) {
        int fixed_point_value = FX_convert(data[i]);
        // Ensure 16-bit representation of the address and data
        // Mask to 16-bit address
        int data_16bit = fixed_point_value & 0xFFFF; // Mask to 16-bit data
        
        fprintf(weight_file, "%04x_%04x\n", weight_addr, data_16bit);
		weight_addr ++; 
    }
}

void write_bias_to_file(float data[], int length) {
   
    for (int i = 0; i < length; i++) {
        int fixed_point_value = FX_convert(data[i]);
        // Ensure 16-bit representation of the address and data
        int data_16bit = fixed_point_value & 0xFFFF; // Mask to 16-bit data
        
        fprintf(bias_file, "%04x_%04x\n", bias_addr, data_16bit);
		bias_addr++;
    }
	
}

// Function to write data to file in "address_data" format
void write_context_to_file(uint32_t data[], int length) {
    for (int i = 0; i < length; i++) {        
        fprintf(context_file, "%04x_%08x\n", ctx_addr, data[i]);
		ctx_addr++;
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

// Function to write data to file in "address_data" format
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



// Helper function to round a value to three decimal places
float fixedpoint_converter(float value) {
	if(value >= 512){
		printf("Value is larger than 512 = %f\n", value);
		value = value - 512;	
	}
    float scalingFactor = 64.0f; // 2^5
    return round(value * scalingFactor) / scalingFactor; 
}

void Padding_Conv1D_0(float input_Pad_Conv[320], float output_Pad_Conv[324]){
	write_to_file2("LDM_File.txt", input_Pad_Conv, 340);
	loop_for_3_channel_pad_0:
	for (int c = 0; c < 1; c++){
		loop_for_channel_pad_0:
		for (int n = 0; n < 324; n++){
			if (n < 2 || n >= 322) output_Pad_Conv[324 * c + n]=0; else output_Pad_Conv[324 * c + n] = input_Pad_Conv[320 * c + n - 2];
		}
	}
}
void Conv1D_0(float Input_Conv[324],float Output_Conv[1280], float bias[8], float kernel[56]){
	loop_for_channel_0:
	int stride = 2;
	int n, y, k, j;

	for (int i = 0; i < 324; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
		// printf("bias[%d] before: %f\n",i,bias[i]);
        bias[i] = fixedpoint_converter(bias[i]);
		// printf("bias[%d] after: %f\n",i,bias[i]);
    }
	for (int i = 0; i < 56; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	
	for ( n = 0; n < 8; n++){
		loop_for_ap_0:
		for ( y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_0:
			for ( k = 0; k < 1; k++){
				loop_for_fa_0:
				for ( j = 0; j < 7; j++){
					s=s+(kernel[1*7*n+7*k+j])*(Input_Conv[324*k+j+y*stride]);
					s=fixedpoint_converter(s);
					// if((((324*k+j+y*stride)%324)>=2&&((324*k+j+y*stride)%324)<322))
						// printf("PE = %d, W_addr = %d, from PE = %d, Read LDM_addr = %d (%d), Data = %f, kernel = %f, s = %f\n",y%20, 1*7*n+7*k+j,(324*k+j+y*stride-2*(k+1))%20, (324*k+j+y*stride-2*(k+1))/20,(324*k+j+y*stride-2*(k+1)),Input_Conv[324*k+j+y*stride], kernel[1*7*n+7*k+j], fixedpoint_converter(s));
					// else 
						// printf("PE = %d, W_addr = %d, from PE = %d, Read Pad_addr = %d, Data = %f, kernel = %f, s = %f\n",y%20,1*7*n+7*k+j,(324*k+j+y*stride-2*(k+1)+20)%20,324*k+j+y*stride,Input_Conv[324*k+j+y*stride], kernel[1*7*n+7*k+j], s);
					}
					
						
					
			}
			Output_Conv[160*n+y]=s+bias[n];
			// printf("PE = %d, bias_addr = %d, Store LDM_addr = %d, s = %f, Output_Conv[%d] = %f\n\n\n",(160*n+y)%20,n,(160*n+y)/20, s, 160*n+y, fixedpoint_converter(Output_Conv[160*n+y]));
			
		}
	}

	for (int i = 0; i < 1280; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
    // write_to_file("Output_Conv.txt", Output_Conv, 1280);
    write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 56);
	int pad_ctx = 2, n_ctx = 7, y_ctx = 7, k_ctx = 0, j_ctx = 6, alu_cfg_ctx = 5, stride_ctx = 1,s_ldm_ctx = 0, d_ldm_ctx = 3, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
	
	// fclose(weight_file);
	// fclose(bias_file);
	// fclose(context_file);
}
 void Activation0(float Input_Activation[1280], float Output_Activation[1280]){
	for (int i = 0; i < 1280; i++){
		if(Input_Activation[i] > 0){
			Output_Activation[i] = Input_Activation[i];
		}else
		{
			Output_Activation[i] = 0;
		}
	}
	
	// write_to_file("Output_Conv.txt", Output_Activation, 1280);
}
void Conv1D_1(float Input_Conv[1280],float Output_Conv[320], float bias[2], float kernel[16]){
	loop_for_channel_1:
	int stride = 1;
	int n, y, k, j;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
	
	// write_to_file2("LDM_File.txt", Input_Conv, 1280);
	
    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 16; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (n = 0; n < 2; n++){
		loop_for_ap_1:
		for (y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_1:
			for (k = 0; k < 8; k++){
				loop_for_fa_1:
				for (j = 0; j < 1; j++){
					s=s+(kernel[8*1*n+1*k+j])*(Input_Conv[160*k+j+y*stride]);
					// printf("kernel[8*1*n+1*k+j] = %d, Input_Conv[160*k+j+y*stride] = %d\n",8*1*n+1*k+j,160*k+j+y*stride);
					// printf("AT PE = %d, kernel[1*7*n+7*k+j] = %d, PE = %d, Read LDM address = %d\n",y%20, 1*7*n+7*k+j,(160*k+j+y*stride)%20, (160*k+j+y*stride)/20);
					
					}
			}
			Output_Conv[160*n+y]=s+bias[n];
			// printf("Output_Conv[160*n+y] = %d, n = %d\n",160*n+y,n);
			// printf("AT PE = %d, bias = %d, Store LDM address = %d\n\n\n",(160*n+y)%20,n,(160*n+y)/20);
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	// write_to_file("Output_Conv.txt", Output_Conv, 320);
	write_bias_to_file(bias, 2);
    write_weight_to_file(kernel, 16);
	int pad_ctx = 0, n_ctx = 1, y_ctx = 7, k_ctx = 7, j_ctx = 0, alu_cfg_ctx = 1, stride_ctx = 0, s_ldm_ctx = 3, d_ldm_ctx = 0, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Conv1D_2(float Input_Conv[1280],float Output_Conv[320], float bias[2], float kernel[16]){
	loop_for_channel_2:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 16; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 2; n++){
		loop_for_ap_2:
		for (int y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_2:
			for (int k = 0; k < 8; k++){
				loop_for_fa_2:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[8*1*n+1*k+j])*(Input_Conv[160*k+j+y*stride]);
					
					 // printf("PE = %d, W_addr = %d, from PE = %d, Read LDM_addr = %d (%d), Data = %f, kernel = %f, s = %f\n",y%20, 8*1*n+1*k+j,(160*k+j+y*stride)%20, (160*k+j+y*stride)/20,(160*k+j+y*stride),Input_Conv[160*k+j+y*stride], kernel[8*1*n+1*k+j], fixedpoint_converter(s));
					}
			}
			Output_Conv[160*n+y]=s+bias[n];
			// printf("PE = %d, bias_addr = %d, bias = %f, Store LDM_addr = %d, s = %f, Output_Conv[%d] = %f\n\n\n",(160*n+y)%20,n,bias[n],(160*n+y)/20, s, 160*n+y, fixedpoint_converter(Output_Conv[160*n+y]));
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	// write_to_file("Output_Conv.txt", Output_Conv, 320);
	write_bias_to_file(bias, 2);
    write_weight_to_file(kernel, 16);
	int pad_ctx = 0, n_ctx = 1, y_ctx = 7, k_ctx = 7, j_ctx = 0, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_3(float input_Pad_Conv[320], float output_Pad_Conv[324]){
	loop_for_3_channel_pad_3:
	for (int c = 0; c < 2; c++){
		loop_for_channel_pad_3:
		for (int n = 0; n < 162; n++){
			if (n < 1 || n >= 161) output_Pad_Conv[162 * c + n]=0; else output_Pad_Conv[162 * c + n] = input_Pad_Conv[160 * c + n - 1];
		}
	}
}
void Conv1D_3(float Input_Conv[324],float Output_Conv[320], float bias[2], float kernel[12]){
	loop_for_channel_3:
	int stride = 1;
	
	for (int i = 0; i < 324; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 12; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 2; n++){
		loop_for_ap_3:
		for (int y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_3:
			for (int k = 0; k < 2; k++){
				loop_for_fa_3:
				for (int j = 0; j < 3; j++){
					s=s+(kernel[2*3*n+3*k+j])*(Input_Conv[162*k+j+y*stride]);
					// if((((162*k+j+y*stride)%162)>=2&&((162*k+j+y*stride)%162)<162))
						// printf("PE = %d, W_addr = %d, from PE = %d, Read LDM_addr = %d (%d)\n",y%20, 162*k+j+y*stride,(162*k+j+y*stride-2*(k+1)-2*k)%20, (162*k+j+y*stride-2*(k+1)-2*k)/20,(162*k+j+y*stride-2*(k+1)-2*k));
					// else 
						// printf("PE = %d, W_addr = %d, from PE = %d, Read Pad_addr = %d\n",y%20,162*k+j+y*stride,(162*k+j+y*stride-2*(k+1)-2*k+20)%20,162*k+j+y*stride);
					}
			}
			Output_Conv[160*n+y]=s+bias[n];
			// printf("Output_Conv[160*n+y] = %d, n = %d\n",160*n+y,n);
			// printf("AT PE = %d, bias = %d, Store LDM address = %d\n\n\n",(160*n+y)%20,n,(160*n+y)/20);
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 2);
    write_weight_to_file(kernel, 12);
	int pad_ctx = 1, n_ctx = 1, y_ctx = 7, k_ctx = 1, j_ctx = 2, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 16;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_4(float input_Pad_Conv[320], float output_Pad_Conv[328]){
	loop_for_3_channel_pad_4:
	for (int c = 0; c < 2; c++){
		loop_for_channel_pad_4:
		for (int n = 0; n < 164; n++){
			if (n < 2 || n >= 162) output_Pad_Conv[164 * c + n]=0; else output_Pad_Conv[164 * c + n] = input_Pad_Conv[160 * c + n - 2];
		}
	}
}
void Conv1D_4(float Input_Conv[328],float Output_Conv[320], float bias[2], float kernel[20]){
	loop_for_channel_4:
	int stride = 1;
	
	for (int i = 0; i < 328; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 20; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 2; n++){
		loop_for_ap_4:
		for (int y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_4:
			for (int k = 0; k < 2; k++){
				loop_for_fa_4:
				for (int j = 0; j < 5; j++){
					s=s+(kernel[2*5*n+5*k+j])*(Input_Conv[164*k+j+y*stride]);
					// if((((164*k+j+y*stride)%164)>=2&&((164*k+j+y*stride)%164)<162))
						// printf("PE = %d, W_addr = %d, from PE = %d, Read LDM_addr = %d (%d)\n",y%20, 2*5*n+5*k+j,(164*k+j+y*stride-2*(k+1))%20, (164*k+j+y*stride-2*(k+1))/20,(164*k+j+y*stride-2*(k+1)));
					// else 
						// printf("PE = %d, W_addr = %d, from PE = %d, Read Pad_addr = %d\n",y%20,2*5*n+5*k+j,(164*k+j+y*stride-2*(k+1)+20)%20, 164*k+j+y*stride);
					}
			}
			Output_Conv[160*n+y]=s+bias[n];
			// printf("PE = %d, bias_addr = %d, Store LDM_addr = %d\n\n\n",(160*n+y)%20,n,(160*n+y)/20);
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 2);
    write_weight_to_file(kernel, 20);
	int pad_ctx = 2, n_ctx = 1, y_ctx = 7, k_ctx = 1, j_ctx = 4, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 32;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_5(float input_Pad_Conv[320], float output_Pad_Conv[332]){
	// write_to_file2("LDM_File.txt", input_Pad_Conv, 320);
	
	loop_for_3_channel_pad_5:
	for (int c = 0; c < 2; c++){
		loop_for_channel_pad_5:
		for (int n = 0; n < 166; n++){
			if (n < 3 || n >= 163) output_Pad_Conv[166 * c + n]=0; else output_Pad_Conv[166 * c + n] = input_Pad_Conv[160 * c + n - 3];
		}
	}
}
void Conv1D_5(float Input_Conv[332],float Output_Conv[320], float bias[2], float kernel[28]){
	loop_for_channel_5:
	int stride = 1;
	
	for (int i = 0; i < 332; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 28; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 2; n++){
		loop_for_ap_5:
		for (int y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_5:
			for (int k = 0; k < 2; k++){
				loop_for_fa_5:
				for (int j = 0; j < 7; j++){
					s=s+(kernel[2*7*n+7*k+j])*(Input_Conv[166*k+j+y*stride]);}
			}
			Output_Conv[160*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 2);
    write_weight_to_file(kernel, 28);
	int pad_ctx = 3, n_ctx = 1, y_ctx = 7, k_ctx = 1, j_ctx = 6, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 48;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
	 
}
 void Activation1(float Input_Activation[1280], float Output_Activation[1280]){
	for (int i = 0; i < 1280; i++){
		if(Input_Activation[i] > 0){
			Output_Activation[i] = Input_Activation[i];
		}else
		{
			Output_Activation[i] = 0;
		}
	}
	
	// write_to_file("Output_Conv.txt", Output_Activation, 1280);
}
void Conv1D_6(float Input_Conv[1280],float Output_Conv[320], float bias[2], float kernel[16]){
	loop_for_channel_6:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 16; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 2; n++){
		loop_for_ap_6:
		for (int y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_6:
			for (int k = 0; k < 8; k++){
				loop_for_fa_6:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[8*1*n+1*k+j])*(Input_Conv[160*k+j+y*stride]);}
			}
			Output_Conv[160*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 2);
    write_weight_to_file(kernel, 16);
	int pad_ctx = 0, n_ctx = 1, y_ctx = 7, k_ctx = 7, j_ctx = 0, alu_cfg_ctx = 1, stride_ctx = 0, s_ldm_ctx = 1, d_ldm_ctx = 0, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Conv1D_7(float Input_Conv[1280],float Output_Conv[320], float bias[2], float kernel[16]){
	loop_for_channel_7:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 16; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 2; n++){
		loop_for_ap_7:
		for (int y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_7:
			for (int k = 0; k < 8; k++){
				loop_for_fa_7:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[8*1*n+1*k+j])*(Input_Conv[160*k+j+y*stride]);}
			}
			Output_Conv[160*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 2);
    write_weight_to_file(kernel, 16);
	int pad_ctx = 0, n_ctx = 1, y_ctx = 7, k_ctx = 7, j_ctx = 0, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
	
	// write_to_file("Output_Conv.txt", Output_Activation, 1280);
}
void Padding_Conv1D_8(float input_Pad_Conv[320], float output_Pad_Conv[324]){
	
	// write_to_file2("LDM_File.txt", input_Pad_Conv, 320);
	loop_for_3_channel_pad_8:
	for (int c = 0; c < 2; c++){
		loop_for_channel_pad_8:
		for (int n = 0; n < 162; n++){
			if (n < 1 || n >= 161) output_Pad_Conv[162 * c + n]=0; else output_Pad_Conv[162 * c + n] = input_Pad_Conv[160 * c + n - 1];
		}
	}
}
void Conv1D_8(float Input_Conv[324],float Output_Conv[320], float bias[2], float kernel[12]){
	loop_for_channel_8:
	int stride = 1;
	
	for (int i = 0; i < 324; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 12; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 2; n++){
		loop_for_ap_8:
		for (int y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_8:
			for (int k = 0; k < 2; k++){
				loop_for_fa_8:
				for (int j = 0; j < 3; j++){
					s=s+(kernel[2*3*n+3*k+j])*(Input_Conv[162*k+j+y*stride]);}
			}
			Output_Conv[160*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 2);
    write_weight_to_file(kernel, 12);
	int pad_ctx = 1, n_ctx = 1, y_ctx = 7, k_ctx = 1, j_ctx = 2, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 16;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_9(float input_Pad_Conv[320], float output_Pad_Conv[328]){
	loop_for_3_channel_pad_9:
	for (int c = 0; c < 2; c++){
		loop_for_channel_pad_9:
		for (int n = 0; n < 164; n++){
			if (n < 2 || n >= 162) output_Pad_Conv[164 * c + n]=0; else output_Pad_Conv[164 * c + n] = input_Pad_Conv[160 * c + n - 2];
		}
	}
}
void Conv1D_9(float Input_Conv[328],float Output_Conv[320], float bias[2], float kernel[20]){
	loop_for_channel_9:
	int stride = 1;
	
	for (int i = 0; i < 328; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 20; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 2; n++){
		loop_for_ap_9:
		for (int y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_9:
			for (int k = 0; k < 2; k++){
				loop_for_fa_9:
				for (int j = 0; j < 5; j++){
					s=s+(kernel[2*5*n+5*k+j])*(Input_Conv[164*k+j+y*stride]);}
			}
			Output_Conv[160*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 2);
    write_weight_to_file(kernel, 20);
	int pad_ctx = 2, n_ctx = 1, y_ctx = 7, k_ctx = 1, j_ctx = 4, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 32;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_10(float input_Pad_Conv[320], float output_Pad_Conv[332]){
	loop_for_3_channel_pad_10:
	for (int c = 0; c < 2; c++){
		loop_for_channel_pad_10:
		for (int n = 0; n < 166; n++){
			if (n < 3 || n >= 163) output_Pad_Conv[166 * c + n]=0; else output_Pad_Conv[166 * c + n] = input_Pad_Conv[160 * c + n - 3];
		}
	}
}
void Conv1D_10(float Input_Conv[332],float Output_Conv[320], float bias[2], float kernel[28]){
	loop_for_channel_10:
	int stride = 1;
	
	for (int i = 0; i < 332; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 2; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 28; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 2; n++){
		loop_for_ap_10:
		for (int y = 0; y < 160; y++){
			float s = 0;
			loop_for_fc_10:
			for (int k = 0; k < 2; k++){
				loop_for_fa_10:
				for (int j = 0; j < 7; j++){
					s=s+(kernel[2*7*n+7*k+j])*(Input_Conv[166*k+j+y*stride]);}
			}
			Output_Conv[160*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 2);
    write_weight_to_file(kernel, 28);
	int pad_ctx = 3, n_ctx = 1, y_ctx = 7, k_ctx = 1, j_ctx = 6, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 48;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
 void Activation2(float Input_Activation[1280], float Output_Activation[1280]){
	for (int i = 0; i < 1280; i++){
		if(Input_Activation[i] > 0){
			Output_Activation[i] = Input_Activation[i];
		}else
		{
			Output_Activation[i] = 0;
		}
	}
	// write_to_file("Output_Conv.txt", Output_Activation, 1280);
}
 void Add2D_0(float input_0[1280], float input_1[1280], float output[1280]) {
	int size =1280;
	for (int i = 0; i < size; i++){
		output[i] = input_0[i] + input_1[i];
	}
	
	// write_to_file("Output_Conv.txt", output, 1280);
		int pad_ctx = 0, n_ctx = 7, y_ctx = 7, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 2, stride_ctx = 0, s_ldm_ctx = 2, d_ldm_ctx = 1, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_11(float input_Pad_Conv[1280], float output_Pad_Conv[1296]){
	// write_to_file2("LDM_File.txt", input_Pad_Conv, 1280);
	loop_for_3_channel_pad_11:
	for (int c = 0; c < 8; c++){
		loop_for_channel_pad_11:
		for (int n = 0; n < 162; n++){
			if (n < 1 || n >= 161) output_Pad_Conv[162 * c + n]=0; else output_Pad_Conv[162 * c + n] = input_Pad_Conv[160 * c + n - 1];
		}
	}
}
void Conv1D_11(float Input_Conv[1296],float Output_Conv[1280], float bias[16], float kernel[640]){
	loop_for_channel_11:
	int stride = 2;
	
	for (int i = 0; i < 1296; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 16; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 640; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 16; n++){
		loop_for_ap_11:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_11:
			for (int k = 0; k < 8; k++){
				loop_for_fa_11:
				for (int j = 0; j < 5; j++){
					s=s+(kernel[8*5*n+5*k+j])*(Input_Conv[162*k+j+y*stride]);
					s=fixedpoint_converter(s);
					
					// if((y%20) == 19){
						// if((((162*k+j+y*stride)%162)>=1&&((162*k+j+y*stride)%162)<161))
							// printf("PE = %d, W_addr = %d, from PE = %d, Read LDM_addr = %d (%d), Data = %f, kernel = %f, s = %f\n",y%20, 8*5*n+5*k+j,(162*k+j+y*stride-(1+2*k))%20, (162*k+j+y*stride-(1+2*k))/20,(162*k+j+y*stride-(1+2*k)),Input_Conv[162*k+j+y*stride], kernel[8*5*n+5*k+j], fixedpoint_converter(s));
						// else 
							// printf("PE = %d, W_addr = %d, from PE = %d, Read Pad_addr = %d, Data = %f, kernel = %f, s = %f\n",y%20,8*5*n+5*k+j,(162*k+j+y*stride-(1+2*k)+20)%20,162*k+j+y*stride,Input_Conv[162*k+j+y*stride], kernel[8*5*n+5*k+j], s);
					// }
				}
			}
			Output_Conv[80*n+y]=s+bias[n];
			// if((y%20) == 19)
				// printf("PE = %d, bias_addr = %d, Store LDM_addr = %d, s = %f, Output_Conv[%d] = %f\n\n\n",(80*n+y)%20,n,(80*n+y)/20, s, 80*n+y, fixedpoint_converter(Output_Conv[80*n+y]));
		}
	}
	
	// for (int n = 15; n>=0; n--){
		// for (int y = 79; y >= 0; y--){
			// if((80*n+y)%20 == 18)
						// printf("PE = %d, Output_Conv[%d] = %f\n",(80*n+y)%20,(80*n+y)/20, fixedpoint_converter(Output_Conv[(80*n+y)]));
		// }
	// }

    // write_to_file("Output_Conv.txt", Output_Conv, 1280);
    // write_to_file("BRAM_File.txt", bias, 16);
    // write_to_file("WRAM_File.txt", kernel, 640);

    // int pad_ctx = 1, n_ctx = 15, y_ctx = 80, k_ctx = 7, j_ctx = 4, alu_cfg_ctx = 1, stride_ctx = 1, resCon_ctx = 0;

    // // Call the function to concatenate inputs into a 28-bit output
    // uint32_t result = concatenate_to_29bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, resCon_ctx);
    
    // // Pass the address of result to write_to_file2
    // write_to_file3("CRAM_File.txt", &result, 1);
	write_bias_to_file(bias, 16);
    write_weight_to_file(kernel, 640);
	int pad_ctx = 1, n_ctx = 15, y_ctx = 3, k_ctx = 7, j_ctx = 4, alu_cfg_ctx = 5, stride_ctx = 1,s_ldm_ctx = 1, d_ldm_ctx = 3, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
	
	for (int i = 0; i < 1280; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
}
 void Activation3(float Input_Activation[1280], float Output_Activation[1280]){
	for (int i = 0; i < 1280; i++){
		if(Input_Activation[i] > 0){
			Output_Activation[i] = Input_Activation[i];
		}else
		{
			Output_Activation[i] = 0;
		}
	}
	// write_to_file("Output_Conv.txt", Output_Activation, 1280);
}
void Conv1D_12(float Input_Conv[1280],float Output_Conv[320], float bias[4], float kernel[64]){
	loop_for_channel_12:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 4; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 64; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 4; n++){
		loop_for_ap_12:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_12:
			for (int k = 0; k < 16; k++){
				loop_for_fa_12:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[16*1*n+1*k+j])*(Input_Conv[80*k+j+y*stride]);}
			}
			Output_Conv[80*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	// write_to_file("Output_Conv.txt", Output_Conv, 320);
	
	write_bias_to_file(bias, 4);
    write_weight_to_file(kernel, 64);
	int pad_ctx = 0, n_ctx = 3, y_ctx = 3, k_ctx = 15, j_ctx = 0, alu_cfg_ctx = 1, stride_ctx = 0, s_ldm_ctx = 3, d_ldm_ctx = 0, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Conv1D_13(float Input_Conv[1280],float Output_Conv[320], float bias[4], float kernel[64]){
	loop_for_channel_13:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 4; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 64; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 4; n++){
		loop_for_ap_13:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_13:
			for (int k = 0; k < 16; k++){
				loop_for_fa_13:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[16*1*n+1*k+j])*(Input_Conv[80*k+j+y*stride]);
						// if((y%20) == 0){
							// printf("PE = %d, W_addr = %d, from PE = %d, Read LDM_addr = %d (%d), Data = %f, kernel = %f, s = %f\n",y%20, 16*1*n+1*k+j,(80*k+j+y*stride)%20, (80*k+j+y*stride)/20,(80*k+j+y*stride),Input_Conv[80*k+j+y*stride], kernel[16*1*n+1*k+j], fixedpoint_converter(s));
						// }
					
					}
			}
			Output_Conv[80*n+y]=s+bias[n];
			
			// if((y%20) == 0)
				// printf("PE = %d, bias_addr = %d, Store LDM_addr = %d, s = %f, Output_Conv[%d] = %f\n\n\n",(80*n+y)%20,n,(80*n+y)/20, s, 80*n+y, fixedpoint_converter(Output_Conv[80*n+y]));
		}
	}
	
	for (int i = 0; i < 320; i++) {
		if(Output_Conv[i]>0)
			Output_Conv[i] = Output_Conv[i];
		else 
			Output_Conv[i] = 0;
    }
	
	// write_to_file("Output_Conv.txt", Output_Conv, 320);
	
	write_bias_to_file(bias, 4);
    write_weight_to_file(kernel, 64);
	int pad_ctx = 0, n_ctx = 3, y_ctx = 3, k_ctx = 15, j_ctx = 0, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
	
}
void Padding_Conv1D_14(float input_Pad_Conv[320], float output_Pad_Conv[328]){
	loop_for_3_channel_pad_14:
	for (int c = 0; c < 4; c++){
		loop_for_channel_pad_14:
		for (int n = 0; n < 82; n++){
			if (n < 1 || n >= 81) output_Pad_Conv[82 * c + n]=0; else output_Pad_Conv[82 * c + n] = input_Pad_Conv[80 * c + n - 1];
		}
	}
}
void Conv1D_14(float Input_Conv[328],float Output_Conv[320], float bias[4], float kernel[48]){
	loop_for_channel_14:
	int stride = 1;
	
	for (int i = 0; i < 328; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 4; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 48; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 4; n++){
		loop_for_ap_14:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_14:
			for (int k = 0; k < 4; k++){
				loop_for_fa_14:
				for (int j = 0; j < 3; j++){
					s=s+(kernel[4*3*n+3*k+j])*(Input_Conv[82*k+j+y*stride]);}
			}
			Output_Conv[80*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 4);
    write_weight_to_file(kernel, 48);
	int pad_ctx = 1, n_ctx = 3, y_ctx = 3, k_ctx = 3, j_ctx = 2, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 16;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_15(float input_Pad_Conv[320], float output_Pad_Conv[336]){
	loop_for_3_channel_pad_15:
	for (int c = 0; c < 4; c++){
		loop_for_channel_pad_15:
		for (int n = 0; n < 84; n++){
			if (n < 2 || n >= 82) output_Pad_Conv[84 * c + n]=0; else output_Pad_Conv[84 * c + n] = input_Pad_Conv[80 * c + n - 2];
		}
	}
}
void Conv1D_15(float Input_Conv[336],float Output_Conv[320], float bias[4], float kernel[80]){
	loop_for_channel_15:
	int stride = 1;
	
	for (int i = 0; i < 336; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 4; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 80; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 4; n++){
		loop_for_ap_15:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_15:
			for (int k = 0; k < 4; k++){
				loop_for_fa_15:
				for (int j = 0; j < 5; j++){
					s=s+(kernel[4*5*n+5*k+j])*(Input_Conv[84*k+j+y*stride]);}
			}
			Output_Conv[80*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 4);
    write_weight_to_file(kernel, 80);
	int pad_ctx = 2, n_ctx = 3, y_ctx = 3, k_ctx = 3, j_ctx = 4, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 32;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
	
}
void Padding_Conv1D_16(float input_Pad_Conv[320], float output_Pad_Conv[344]){
	loop_for_3_channel_pad_16:
	for (int c = 0; c < 4; c++){
		loop_for_channel_pad_16:
		for (int n = 0; n < 86; n++){
			if (n < 3 || n >= 83) output_Pad_Conv[86 * c + n]=0; else output_Pad_Conv[86 * c + n] = input_Pad_Conv[80 * c + n - 3];
		}
	}
}
void Conv1D_16(float Input_Conv[344],float Output_Conv[320], float bias[4], float kernel[112]){
	loop_for_channel_16:
	int stride = 1;
	
	for (int i = 0; i < 344; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 4; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 112; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 4; n++){
		loop_for_ap_16:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_16:
			for (int k = 0; k < 4; k++){
				loop_for_fa_16:
				for (int j = 0; j < 7; j++){
					s=s+(kernel[4*7*n+7*k+j])*(Input_Conv[86*k+j+y*stride]);}
			}
			Output_Conv[80*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 4);
    write_weight_to_file(kernel, 112);
	int pad_ctx = 3, n_ctx = 3, y_ctx = 3, k_ctx = 3, j_ctx = 6, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 48;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
 void Activation4(float Input_Activation[1280], float Output_Activation[1280]){
	for (int i = 0; i < 1280; i++){
		if(Input_Activation[i] > 0){
			Output_Activation[i] = Input_Activation[i];
		}else
		{
			Output_Activation[i] = 0;
		}
	}
	
	// write_to_file("Output_Conv.txt", Output_Activation, 1280);
}
void Conv1D_17(float Input_Conv[1280],float Output_Conv[320], float bias[4], float kernel[64]){
	loop_for_channel_17:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 4; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 64; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 4; n++){
		loop_for_ap_17:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_17:
			for (int k = 0; k < 16; k++){
				loop_for_fa_17:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[16*1*n+1*k+j])*(Input_Conv[80*k+j+y*stride]);}
			}
			Output_Conv[80*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 4);
    write_weight_to_file(kernel, 64);
	int pad_ctx = 0, n_ctx = 3, y_ctx = 3, k_ctx = 15, j_ctx = 0, alu_cfg_ctx = 1, stride_ctx = 0, s_ldm_ctx = 2, d_ldm_ctx = 0, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Conv1D_18(float Input_Conv[1280],float Output_Conv[320], float bias[4], float kernel[64]){
	loop_for_channel_18:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 4; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 64; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	
	for (int n = 0; n < 4; n++){
		loop_for_ap_18:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_18:
			for (int k = 0; k < 16; k++){
				loop_for_fa_18:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[16*1*n+1*k+j])*(Input_Conv[80*k+j+y*stride]);}
			}
			Output_Conv[80*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 4);
    write_weight_to_file(kernel, 64);
	int pad_ctx = 0, n_ctx = 3, y_ctx = 3, k_ctx = 15, j_ctx = 0, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
	
}
void Padding_Conv1D_19(float input_Pad_Conv[320], float output_Pad_Conv[328]){
	loop_for_3_channel_pad_19:
	for (int c = 0; c < 4; c++){
		loop_for_channel_pad_19:
		for (int n = 0; n < 82; n++){
			if (n < 1 || n >= 81) output_Pad_Conv[82 * c + n]=0; else output_Pad_Conv[82 * c + n] = input_Pad_Conv[80 * c + n - 1];
		}
	}
}
void Conv1D_19(float Input_Conv[328],float Output_Conv[320], float bias[4], float kernel[48]){
	loop_for_channel_19:
	int stride = 1;
	
	for (int i = 0; i < 328; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 4; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 48; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 4; n++){
		loop_for_ap_19:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_19:
			for (int k = 0; k < 4; k++){
				loop_for_fa_19:
				for (int j = 0; j < 3; j++){
					s=s+(kernel[4*3*n+3*k+j])*(Input_Conv[82*k+j+y*stride]);}
			}
			Output_Conv[80*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 4);
    write_weight_to_file(kernel, 48);
	int pad_ctx = 1, n_ctx = 3, y_ctx = 3, k_ctx = 3, j_ctx = 2, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 16;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_20(float input_Pad_Conv[320], float output_Pad_Conv[336]){
	loop_for_3_channel_pad_20:
	for (int c = 0; c < 4; c++){
		loop_for_channel_pad_20:
		for (int n = 0; n < 84; n++){
			if (n < 2 || n >= 82) output_Pad_Conv[84 * c + n]=0; else output_Pad_Conv[84 * c + n] = input_Pad_Conv[80 * c + n - 2];
		}
	}
}
void Conv1D_20(float Input_Conv[336],float Output_Conv[320], float bias[4], float kernel[80]){
	loop_for_channel_20:
	int stride = 1;
	
	for (int i = 0; i < 336; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 4; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 80; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 4; n++){
		loop_for_ap_20:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_20:
			for (int k = 0; k < 4; k++){
				loop_for_fa_20:
				for (int j = 0; j < 5; j++){
					s=s+(kernel[4*5*n+5*k+j])*(Input_Conv[84*k+j+y*stride]);}
			}
			Output_Conv[80*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 4);
    write_weight_to_file(kernel, 80);
	int pad_ctx = 2, n_ctx = 3, y_ctx = 3, k_ctx = 3, j_ctx = 4, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 32;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_21(float input_Pad_Conv[320], float output_Pad_Conv[344]){
	loop_for_3_channel_pad_21:
	for (int c = 0; c < 4; c++){
		loop_for_channel_pad_21:
		for (int n = 0; n < 86; n++){
			if (n < 3 || n >= 83) output_Pad_Conv[86 * c + n]=0; else output_Pad_Conv[86 * c + n] = input_Pad_Conv[80 * c + n - 3];
		}
	}
}
void Conv1D_21(float Input_Conv[344],float Output_Conv[320], float bias[4], float kernel[112]){
	loop_for_channel_21:
	int stride = 1;
	
	for (int i = 0; i < 344; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 4; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 112; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 4; n++){
		loop_for_ap_21:
		for (int y = 0; y < 80; y++){
			float s = 0;
			loop_for_fc_21:
			for (int k = 0; k < 4; k++){
				loop_for_fa_21:
				for (int j = 0; j < 7; j++){
					s=s+(kernel[4*7*n+7*k+j])*(Input_Conv[86*k+j+y*stride]);}
			}
			Output_Conv[80*n+y]=s+bias[n];
		}
	}
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 4);
    write_weight_to_file(kernel, 112);
	int pad_ctx = 3, n_ctx = 3, y_ctx = 3, k_ctx = 3, j_ctx = 6, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 48;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
 void Activation5(float Input_Activation[1280], float Output_Activation[1280]){
	for (int i = 0; i < 1280; i++){
		if(Input_Activation[i] > 0){
			Output_Activation[i] = Input_Activation[i];
		}else
		{
			Output_Activation[i] = 0;
		}
	}
	// write_to_file("Output_Conv.txt", Output_Activation, 1280);
}
 void Add2D_1(float input_0[1280], float input_1[1280], float output[1280]) {
	int size =1280;
	for (int i = 0; i < size; i++){
		output[i] = input_0[i] + input_1[i];
	}
	
	// write_to_file("Output_Conv.txt", output, 1280);
	// write_to_file("Output_Conv.txt", output, 1280);
	int pad_ctx = 0, n_ctx = 7, y_ctx = 7, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 2, stride_ctx = 0, s_ldm_ctx = 1, d_ldm_ctx = 0, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_22(float input_Pad_Conv[1280], float output_Pad_Conv[1280]){
	loop_for_3_channel_pad_22:
	for (int c = 0; c < 16; c++){
		loop_for_channel_pad_22:
		for (int n = 0; n < 80; n++){
			if (n < 0 || n >= 80) output_Pad_Conv[80 * c + n]=0; else output_Pad_Conv[80 * c + n] = input_Pad_Conv[80 * c + n - 0];
		}
	}
}
void Conv1D_22(float Input_Conv[1280],float Output_Conv[1280], float bias[32], float kernel[1536]){
	loop_for_channel_22:
	int stride = 2;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 32; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 1536; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 32; n++){
		loop_for_ap_22:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_22:
			for (int k = 0; k < 16; k++){
				loop_for_fa_22:
				for (int j = 0; j < 3; j++){
					s=s+(kernel[16*3*n+3*k+j])*(Input_Conv[80*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 1280; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	// write_to_file("Output_Conv.txt", Output_Conv, 1280);
	write_bias_to_file(bias, 32);
    write_weight_to_file(kernel, 1536);
	int pad_ctx = 0, n_ctx = 31, y_ctx = 1, k_ctx = 15, j_ctx = 2, alu_cfg_ctx = 5, stride_ctx = 1,s_ldm_ctx = 0, d_ldm_ctx = 3, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
 void Activation6(float Input_Activation[1280], float Output_Activation[1280]){
	for (int i = 0; i < 1280; i++){
		if(Input_Activation[i] > 0){
			Output_Activation[i] = Input_Activation[i];
		}else
		{
			Output_Activation[i] = 0;
		}
	}
	
	write_to_file("Output_Conv.txt", Output_Activation, 1280);
}
void Conv1D_23(float Input_Conv[1280],float Output_Conv[320], float bias[8], float kernel[256]){
	loop_for_channel_23:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 256; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 8; n++){
		loop_for_ap_23:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_23:
			for (int k = 0; k < 32; k++){
				loop_for_fa_23:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[32*1*n+1*k+j])*(Input_Conv[40*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 256);
	int pad_ctx = 0, n_ctx = 7, y_ctx = 1, k_ctx = 31, j_ctx = 0, alu_cfg_ctx = 1, stride_ctx = 0, s_ldm_ctx = 3, d_ldm_ctx = 0, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Conv1D_24(float Input_Conv[1280],float Output_Conv[320], float bias[8], float kernel[256]){
	loop_for_channel_24:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 256; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 8; n++){
		loop_for_ap_24:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_24:
			for (int k = 0; k < 32; k++){
				loop_for_fa_24:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[32*1*n+1*k+j])*(Input_Conv[40*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 256);
	int pad_ctx = 0, n_ctx = 7, y_ctx = 1, k_ctx = 31, j_ctx = 0, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
	
}
void Padding_Conv1D_25(float input_Pad_Conv[320], float output_Pad_Conv[336]){
	loop_for_3_channel_pad_25:
	for (int c = 0; c < 8; c++){
		loop_for_channel_pad_25:
		for (int n = 0; n < 42; n++){
			if (n < 1 || n >= 41) output_Pad_Conv[42 * c + n]=0; else output_Pad_Conv[42 * c + n] = input_Pad_Conv[40 * c + n - 1];
		}
	}
}
void Conv1D_25(float Input_Conv[336],float Output_Conv[320], float bias[8], float kernel[192]){
	loop_for_channel_25:
	int stride = 1;
	
	for (int i = 0; i < 336; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 192; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 8; n++){
		loop_for_ap_25:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_25:
			for (int k = 0; k < 8; k++){
				loop_for_fa_25:
				for (int j = 0; j < 3; j++){
					s=s+(kernel[8*3*n+3*k+j])*(Input_Conv[42*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 192);
	int pad_ctx = 1, n_ctx = 7, y_ctx = 1, k_ctx = 7, j_ctx = 2, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 16;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_26(float input_Pad_Conv[320], float output_Pad_Conv[352]){
	loop_for_3_channel_pad_26:
	for (int c = 0; c < 8; c++){
		loop_for_channel_pad_26:
		for (int n = 0; n < 44; n++){
			if (n < 2 || n >= 42) output_Pad_Conv[44 * c + n]=0; else output_Pad_Conv[44 * c + n] = input_Pad_Conv[40 * c + n - 2];
		}
	}
}
void Conv1D_26(float Input_Conv[352],float Output_Conv[320], float bias[8], float kernel[320]){
	loop_for_channel_26:
	int stride = 1;
	
	for (int i = 0; i < 352; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 320; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 8; n++){
		loop_for_ap_26:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_26:
			for (int k = 0; k < 8; k++){
				loop_for_fa_26:
				for (int j = 0; j < 5; j++){
					s=s+(kernel[8*5*n+5*k+j])*(Input_Conv[44*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 320);
	int pad_ctx = 2, n_ctx = 7, y_ctx = 1, k_ctx = 7, j_ctx = 4, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 32;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_27(float input_Pad_Conv[320], float output_Pad_Conv[368]){
	loop_for_3_channel_pad_27:
	for (int c = 0; c < 8; c++){
		loop_for_channel_pad_27:
		for (int n = 0; n < 46; n++){
			if (n < 3 || n >= 43) output_Pad_Conv[46 * c + n]=0; else output_Pad_Conv[46 * c + n] = input_Pad_Conv[40 * c + n - 3];
		}
	}
}
void Conv1D_27(float Input_Conv[368],float Output_Conv[320], float bias[8], float kernel[448]){
	loop_for_channel_27:
	int stride = 1;
	
	for (int i = 0; i < 368; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 448; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 8; n++){
		loop_for_ap_27:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_27:
			for (int k = 0; k < 8; k++){
				loop_for_fa_27:
				for (int j = 0; j < 7; j++){
					s=s+(kernel[8*7*n+7*k+j])*(Input_Conv[46*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 448);
	int pad_ctx = 3, n_ctx = 7, y_ctx = 1, k_ctx = 7, j_ctx = 6, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 48;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
 void Activation7(float Input_Activation[1280], float Output_Activation[1280]){
	for (int i = 0; i < 1280; i++){
		if(Input_Activation[i] > 0){
			Output_Activation[i] = Input_Activation[i];
		}else
		{
			Output_Activation[i] = 0;
		}
	}
	// write_to_file("Output_Conv.txt", Output_Activation, 1280);
}
void Conv1D_28(float Input_Conv[1280],float Output_Conv[320], float bias[8], float kernel[256]){
	loop_for_channel_28:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 256; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 8; n++){
		loop_for_ap_28:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_28:
			for (int k = 0; k < 32; k++){
				loop_for_fa_28:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[32*1*n+1*k+j])*(Input_Conv[40*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 256);
	int pad_ctx = 0, n_ctx = 7, y_ctx = 1, k_ctx = 31, j_ctx = 0, alu_cfg_ctx = 1, stride_ctx = 0, s_ldm_ctx = 1, d_ldm_ctx = 0, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Conv1D_29(float Input_Conv[1280],float Output_Conv[320], float bias[8], float kernel[256]){
	loop_for_channel_29:
	int stride = 1;
	
	for (int i = 0; i < 1280; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 256; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 8; n++){
		loop_for_ap_29:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_29:
			for (int k = 0; k < 32; k++){
				loop_for_fa_29:
				for (int j = 0; j < 1; j++){
					s=s+(kernel[32*1*n+1*k+j])*(Input_Conv[40*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 256);
	int pad_ctx = 0, n_ctx = 7, y_ctx = 1, k_ctx = 31, j_ctx = 0, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
	
}
void Padding_Conv1D_30(float input_Pad_Conv[320], float output_Pad_Conv[336]){
	loop_for_3_channel_pad_30:
	for (int c = 0; c < 8; c++){
		loop_for_channel_pad_30:
		for (int n = 0; n < 42; n++){
			if (n < 1 || n >= 41) output_Pad_Conv[42 * c + n]=0; else output_Pad_Conv[42 * c + n] = input_Pad_Conv[40 * c + n - 1];
		}
	}
}
void Conv1D_30(float Input_Conv[336],float Output_Conv[320], float bias[8], float kernel[192]){
	loop_for_channel_30:
	int stride = 1;
	
	for (int i = 0; i < 336; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 192; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 8; n++){
		loop_for_ap_30:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_30:
			for (int k = 0; k < 8; k++){
				loop_for_fa_30:
				for (int j = 0; j < 3; j++){
					s=s+(kernel[8*3*n+3*k+j])*(Input_Conv[42*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 192);
	int pad_ctx = 1, n_ctx = 7, y_ctx = 1, k_ctx = 7, j_ctx = 2, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 16;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
	
}
void Padding_Conv1D_31(float input_Pad_Conv[320], float output_Pad_Conv[352]){
	loop_for_3_channel_pad_31:
	for (int c = 0; c < 8; c++){
		loop_for_channel_pad_31:
		for (int n = 0; n < 44; n++){
			if (n < 2 || n >= 42) output_Pad_Conv[44 * c + n]=0; else output_Pad_Conv[44 * c + n] = input_Pad_Conv[40 * c + n - 2];
		}
	}
}
void Conv1D_31(float Input_Conv[352],float Output_Conv[320], float bias[8], float kernel[320]){
	loop_for_channel_31:
	int stride = 1;
	
	for (int i = 0; i < 352; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 320; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 8; n++){
		loop_for_ap_31:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_31:
			for (int k = 0; k < 8; k++){
				loop_for_fa_31:
				for (int j = 0; j < 5; j++){
					s=s+(kernel[8*5*n+5*k+j])*(Input_Conv[44*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 320);
	int pad_ctx = 2, n_ctx = 7, y_ctx = 1, k_ctx = 7, j_ctx = 4, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 32;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
void Padding_Conv1D_32(float input_Pad_Conv[320], float output_Pad_Conv[368]){
	loop_for_3_channel_pad_32:
	for (int c = 0; c < 8; c++){
		loop_for_channel_pad_32:
		for (int n = 0; n < 46; n++){
			if (n < 3 || n >= 43) output_Pad_Conv[46 * c + n]=0; else output_Pad_Conv[46 * c + n] = input_Pad_Conv[40 * c + n - 3];
		}
	}
}
void Conv1D_32(float Input_Conv[368],float Output_Conv[320], float bias[8], float kernel[448]){
	loop_for_channel_32:
	int stride = 1;
	
	for (int i = 0; i < 368; i++) {
		// printf("Input_Conv[%d] before: %f\n",i,Input_Conv[i]);
        Input_Conv[i] = fixedpoint_converter(Input_Conv[i]);
		// printf("Input_Conv[%d] after: %f\n",i,Input_Conv[i]);
    }
    for (int i = 0; i < 8; i++) {
        bias[i] = fixedpoint_converter(bias[i]);
    }
	for (int i = 0; i < 448; i++) {
        kernel[i] = fixedpoint_converter(kernel[i]);
    }
	
	for (int n = 0; n < 8; n++){
		loop_for_ap_32:
		for (int y = 0; y < 40; y++){
			float s = 0;
			loop_for_fc_32:
			for (int k = 0; k < 8; k++){
				loop_for_fa_32:
				for (int j = 0; j < 7; j++){
					s=s+(kernel[8*7*n+7*k+j])*(Input_Conv[46*k+j+y*stride]);}
			}
			Output_Conv[40*n+y]=s+bias[n];
		}
	}
	
	for (int i = 0; i < 320; i++) {
        Output_Conv[i] = fixedpoint_converter(Output_Conv[i]);
    }
	
	write_bias_to_file(bias, 8);
    write_weight_to_file(kernel, 448);
	int pad_ctx = 3, n_ctx = 7, y_ctx = 1, k_ctx = 7, j_ctx = 6, alu_cfg_ctx = 5, stride_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 2, sa_ldm_ctx = 48;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}
 void Activation8(float Input_Activation[1280], float Output_Activation[1280]){
	for (int i = 0; i < 1280; i++){
		if(Input_Activation[i] > 0){
			Output_Activation[i] = Input_Activation[i];
		}else
		{
			Output_Activation[i] = 0;
		}
	}
	
	// write_to_file("Output_Conv.txt", Output_Activation, 1280);
}
 void Add2D_2(float input_0[1280], float input_1[1280], float output[1280]) {
	int size =1280;
	for (int i = 0; i < size; i++){
		output[i] = input_0[i] + input_1[i];
	}
	write_to_file("Output_Conv.txt", output, 1280);
	int pad_ctx = 0, n_ctx = 7, y_ctx = 7, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 2, stride_ctx = 0, s_ldm_ctx = 2, d_ldm_ctx = 0, sa_ldm_ctx = 0;
    uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}


void Padding_Pool_0(float input_Pad_Pool[1280], float output_Pad_Pool[2568]){
	loop_for_3_channel_pad_0:
	for (int c = 0; c < 8; c++){
		loop_for_channel_pad_0:
		for (int n = 0; n < 321; n++){
			if (n >= 321) output_Pad_Pool[321 * c + n]=0; else output_Pad_Pool[321 * c + n] = input_Pad_Pool[160 * c + n];
			// printf("output_Pad_Pool[%d] = input_Pad_Pool[%d] from PE %d, LDM depth = %d, Data = %f\n",321 * c + n,160 * c + n, (160 * c + n)%20,(160 * c + n)/20, input_Pad_Pool[160 * c + n]);
		}
	}
}
void Max_Pool1D_0(float input_MaxPooling[2568], float output_MaxPooling[1280]){
	int PoolSize = 3;
	int stride= 1;
	int index = 0;
	loop_for_channel_pool_0:
	for (int z = 0; z < 8; z++){
		index = 0;
		loop_for_weight_pool_0:
		for (int y = 0; y < 160; y++){
			float max = -10;
			for (int j = 0; j < PoolSize; j++)
			{
				int pool_index = 321 * z + j + y * stride;
				float pool_value = input_MaxPooling[pool_index];
				
				// printf("input_MaxPooling[%d], Data = %f\n",pool_index, input_MaxPooling[pool_index]);
				if (pool_value > max) max=pool_value;
			}
			int out_index = 160 * z + index;
			output_MaxPooling[out_index]=max;
			index++;
		}
	}
	
		// write_to_file("Output_Conv.txt", output_MaxPooling, 1280);
		
		int pad_ctx = 0, n_ctx = 7, y_ctx = 7, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 3, stride_ctx = 0, s_ldm_ctx = 3, d_ldm_ctx = 0, sa_ldm_ctx = 0;

		// Call the function to concatenate inputs into a 28-bit output
		uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
		write_context_to_file( &result, 1);
}
void Padding_Pool_1(float input_Pad_Pool[1280], float output_Pad_Pool[1296]){
	loop_for_3_channel_pad_1:
	for (int c = 0; c < 8; c++){
		loop_for_channel_pad_1:
		for (int n = 0; n < 162; n++){
			if (n < 1 || n >= 161){
				output_Pad_Pool[162 * c + n]=0; 
				// printf("output_Pad_Pool[%d] = padding from PE %d, Data = 0\n",162 * c + n,(160 * c + n - 1 + 20)%20);
			}			
			else {
				output_Pad_Pool[162 * c + n] = input_Pad_Pool[160 * c + n - 1];
			// printf("output_Pad_Pool[%d] = input_Pad_Pool[%d] from PE %d, LDM depth = %d, Data = %f\n",162 * c + n,160 * c + n - 1, (160 * c + n - 1)%20,(160 * c + n - 1)/20, input_Pad_Pool[160 * c + n - 1]);
			}
		}
	}
		
}
void Max_Pool1D_1(float input_MaxPooling[1296], float output_MaxPooling[1280]){
	int PoolSize = 3;
	int stride= 1;
	int index = 0;
	loop_for_channel_pool_1:
	for (int z = 0; z < 8; z++){
		index = 0;
		loop_for_weight_pool_1:
		for (int y = 0; y < 160; y++){
			float max = -10;
			for (int j = 0; j < PoolSize; j++)
			{
				int pool_index = 162 * z + j + y * stride;
				float pool_value = input_MaxPooling[pool_index];
				if (pool_value > max) max=pool_value;
			}
			int out_index = 160 * z + index;
			output_MaxPooling[out_index]=max;
			index++;
		}
	}
	// write_to_file("Output_Conv.txt", output_MaxPooling, 1280);
	int pad_ctx = 1, n_ctx = 7, y_ctx = 7, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 3, stride_ctx = 0, s_ldm_ctx = 1, d_ldm_ctx = 0, sa_ldm_ctx = 0;

		// Call the function to concatenate inputs into a 28-bit output
		uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
		write_context_to_file( &result, 1);
}
void Padding_Pool_2(float input_Pad_Pool[1280], float output_Pad_Pool[1312]){
	loop_for_3_channel_pad_2:
	for (int c = 0; c < 16; c++){
		loop_for_channel_pad_2:
		for (int n = 0; n < 82; n++){
			if (n < 1 || n >= 81) output_Pad_Pool[82 * c + n]=0; else output_Pad_Pool[82 * c + n] = input_Pad_Pool[80 * c + n - 1];
		}
	}
}
void Max_Pool1D_2(float input_MaxPooling[1312], float output_MaxPooling[1280]){
	int PoolSize = 3;
	int stride= 1;
	int index = 0;
	loop_for_channel_pool_2:
	for (int z = 0; z < 16; z++){
		index = 0;
		loop_for_weight_pool_2:
		for (int y = 0; y < 80; y++){
			float max = -10;
			for (int j = 0; j < PoolSize; j++)
			{
				int pool_index = 82 * z + j + y * stride;
				float pool_value = input_MaxPooling[pool_index];
				if (pool_value > max) max=pool_value;
			}
			int out_index = 80 * z + index;
			output_MaxPooling[out_index]=max;
			index++;
		}
	}
	
		// write_to_file("Output_Conv.txt", output_MaxPooling, 1280);
		int pad_ctx = 1, n_ctx = 15, y_ctx = 3, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 3, stride_ctx = 0, s_ldm_ctx = 3, d_ldm_ctx = 0, sa_ldm_ctx = 0;

		// Call the function to concatenate inputs into a 28-bit output
		uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
		write_context_to_file( &result, 1);
}
void Padding_Pool_3(float input_Pad_Pool[1280], float output_Pad_Pool[1312]){
	loop_for_3_channel_pad_3:
	for (int c = 0; c < 16; c++){
		loop_for_channel_pad_3:
		for (int n = 0; n < 82; n++){
			if (n < 1 || n >= 81) output_Pad_Pool[82 * c + n]=0; else output_Pad_Pool[82 * c + n] = input_Pad_Pool[80 * c + n - 1];
		}
	}
}
void Max_Pool1D_3(float input_MaxPooling[1312], float output_MaxPooling[1280]){
	int PoolSize = 3;
	int stride= 1;
	int index = 0;
	loop_for_channel_pool_3:
	for (int z = 0; z < 16; z++){
		index = 0;
		loop_for_weight_pool_3:
		for (int y = 0; y < 80; y++){
			float max = -10;
			for (int j = 0; j < PoolSize; j++)
			{
				int pool_index = 82 * z + j + y * stride;
				float pool_value = input_MaxPooling[pool_index];
				if (pool_value > max) max=pool_value;
			}
			int out_index = 80 * z + index;
			output_MaxPooling[out_index]=max;
			index++;
		}
	}
	
	int pad_ctx = 1, n_ctx = 15, y_ctx = 3, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 3, stride_ctx = 0, s_ldm_ctx = 2, d_ldm_ctx = 0, sa_ldm_ctx = 0;

		// Call the function to concatenate inputs into a 28-bit output
		uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
		write_context_to_file( &result, 1);
}
void Padding_Pool_4(float input_Pad_Pool[1280], float output_Pad_Pool[1344]){
	loop_for_3_channel_pad_4:
	for (int c = 0; c < 32; c++){
		loop_for_channel_pad_4:
		for (int n = 0; n < 42; n++){
			if (n < 1 || n >= 41) output_Pad_Pool[42 * c + n]=0; else output_Pad_Pool[42 * c + n] = input_Pad_Pool[40 * c + n - 1];
		}
	}
}
void Max_Pool1D_4(float input_MaxPooling[1344], float output_MaxPooling[1280]){
	int PoolSize = 3;
	int stride= 1;
	int index = 0;
	loop_for_channel_pool_4:
	for (int z = 0; z < 32; z++){
		index = 0;
		loop_for_weight_pool_4:
		for (int y = 0; y < 40; y++){
			float max = -10;
			for (int j = 0; j < PoolSize; j++)
			{
				int pool_index = 42 * z + j + y * stride;
				float pool_value = input_MaxPooling[pool_index];
				if (pool_value > max) max=pool_value;
			}
			int out_index = 40 * z + index;
			output_MaxPooling[out_index]=max;
			index++;
		}
	}
	
	int pad_ctx = 1, n_ctx = 31, y_ctx = 1, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 3, stride_ctx = 0, s_ldm_ctx = 3, d_ldm_ctx = 0, sa_ldm_ctx = 0;

		// Call the function to concatenate inputs into a 28-bit output
		uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
		write_context_to_file( &result, 1);
}
void Padding_Pool_5(float input_Pad_Pool[1280], float output_Pad_Pool[1344]){
	loop_for_3_channel_pad_5:
	for (int c = 0; c < 32; c++){
		loop_for_channel_pad_5:
		for (int n = 0; n < 42; n++){
			if (n < 1 || n >= 41) output_Pad_Pool[42 * c + n]=0; else output_Pad_Pool[42 * c + n] = input_Pad_Pool[40 * c + n - 1];
		}
	}
}
void Max_Pool1D_5(float input_MaxPooling[1344], float output_MaxPooling[1280]){
	int PoolSize = 3;
	int stride= 1;
	int index = 0;
	loop_for_channel_pool_5:
	for (int z = 0; z < 32; z++){
		index = 0;
		loop_for_weight_pool_5:
		for (int y = 0; y < 40; y++){
			float max = -10;
			for (int j = 0; j < PoolSize; j++)
			{
				int pool_index = 42 * z + j + y * stride;
				float pool_value = input_MaxPooling[pool_index];
				if (pool_value > max) max=pool_value;
			}
			int out_index = 40 * z + index;
			output_MaxPooling[out_index]=max;
			index++;
		}
	}
	
	int pad_ctx = 1, n_ctx = 31, y_ctx = 1, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 3, stride_ctx = 0, s_ldm_ctx = 1, d_ldm_ctx = 0, sa_ldm_ctx = 0;

	// Call the function to concatenate inputs into a 28-bit output
	uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
	write_context_to_file( &result, 1);
}

// Function to convert a 16-bit fixed-point hex value to a float
float fixed_point_to_float(int16_t fixed_point_value) {
    int sign = (fixed_point_value & 0x8000) ? -1 : 1;
    int16_t magnitude = (fixed_point_value & 0x7FFF); // Mask to get 15-bit magnitude
    float float_value = (float)magnitude / SCALE_FACTOR;
    return sign * float_value;
}

void GlobalAveragePool1D(float input_GlobalAveragePool1D[1280], float output_GlobalAveragePool1D[32]) {
    FILE *file = fopen("/home/hoailuan/Research/2024/ECG_Diem/mini_inception_1280_Test_Index/output2.txt", "r");
    if (!file) {
        printf("Error: Unable to open file for reading.\n");
        return;
    }

    int16_t hex_values[NUM_VALUES];
    float input[NUM_VALUES];
	float test[32];
    // Load hex values from the file
    for (int i = 0; i < NUM_VALUES; i++) {
        if (fscanf(file, "%hx", &hex_values[i]) != 1) {
            printf("Error: Unable to read hex value at index %d.\n", i);
            fclose(file);
            return;
        }
    }
    fclose(file);

    // Convert each 16-bit fixed-point hex value to float
    for (int i = 0; i < NUM_VALUES; i++) {
        input[i] = fixed_point_to_float(hex_values[i]);
		// printf("input[%d] = %f, input_GlobalAveragePool1D[%d] = %f\n",i, input[i], i, input_GlobalAveragePool1D[i]);
    }

    // Global Average Pooling
    for (int i = 0; i < 32; i++) {
        float avg = 0;
        for (int j = 0; j < 40; j++) {
            avg += input[40 * i + j];
        }
        output_GlobalAveragePool1D[i] = avg / 40;
    }
	
	for (int i = 0; i < 32; i++) {
        float avg = 0;
        for (int j = 0; j < 40; j++) {
            avg += input_GlobalAveragePool1D[40 * i + j];
        }
        test[i] = avg / 40;
		printf("test[%d] = %f, output_GlobalAveragePool1D[%d] = %f\n",i, test[i], i, output_GlobalAveragePool1D[i]);
    }
}

void Dense_0(float input_Dense[32],float &output_Dense,float bias[5],float weight[160]){
	float out_Dense[5];

    for (int i = 0; i < 160; i++) {
        fprintf(file1, "%f\n", weight[i]);
    }

    fclose(file1);

    for (int i = 0; i < 5; i++) {
        fprintf(file2, "%f\n", bias[i]);
    }

    fclose(file2);
	
	loop_for_a_Dense_0:
	for (int i = 0; i < 5; i++){
		float s=0;
		loop_for_b_Dense_0:
		for (int j = 0; j < 32; j++){
			s+=input_Dense[j]*weight[j*5+i];
		}
		out_Dense[i]=s+bias[i];
	}
	int maxindex = 0;
	float max=out_Dense[0];
	loop_detect:
	for (int i=0; i<5; i++){
		if (out_Dense[i]> max) {
			max=out_Dense[i];
			maxindex=i;
		}
	}
	output_Dense = maxindex;
	

}

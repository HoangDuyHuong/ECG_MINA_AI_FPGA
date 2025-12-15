#include <stdio.h>
#include <stdint.h>  // Include for uint32_t and int16_t types
#include <math.h>    // Include math.h for round function

// Define bit lengths as macros
#define CTX_BITS       32  // Total bits in the final result
#define PAD_BITS       2
#define N_BITS         5
#define Y_BITS         3
#define K_BITS         5
#define J_BITS         3
#define ALU_CFG_BITS   3
#define STRIDE_BITS    1
#define ResCon_BITS    1
#define S_LDM_BITS     2
#define D_LDM_BITS     1
#define SA_LDM_BITS    6

// Function to concatenate inputs into a 32-bit integer
uint32_t concatenate_to_32bit(int pad, int n, int y, int k, int j, int alu_cfg, int stride, int resCon, int s_ldm, int d_ldm, int sa_ldm) {
    uint32_t result = 0;

    // Ensure inputs are within their respective bit limits
    pad     &= (1 << PAD_BITS) - 1;
    n       &= (1 << N_BITS) - 1;
    y       &= (1 << Y_BITS) - 1;
    k       &= (1 << K_BITS) - 1;
    j       &= (1 << J_BITS) - 1;
    alu_cfg &= (1 << ALU_CFG_BITS) - 1;
    stride  &= (1 << STRIDE_BITS) - 1;
    resCon  &= (1 << ResCon_BITS) - 1;
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
    result |= (resCon  << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS - ResCon_BITS));  // Residual Connection bit
    result |= (s_ldm   << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS - ResCon_BITS - S_LDM_BITS));  // S_LDM bits
    result |= (d_ldm   << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS - ResCon_BITS - S_LDM_BITS - D_LDM_BITS));  // D_LDM bit
    result |= (sa_ldm  << (CTX_BITS - PAD_BITS - N_BITS - Y_BITS - K_BITS - J_BITS - ALU_CFG_BITS - STRIDE_BITS - ResCon_BITS - S_LDM_BITS - D_LDM_BITS - SA_LDM_BITS));  // SA_LDM bits

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
	void write_to_file(const char* filename, float data[], int length) {
		FILE *file = fopen(filename, "w");
		if (file == NULL) {
			printf("Error: Unable to open file %s for writing.\n", filename);
			return;
		}

		for (int i = 0; i < length; i++) {
			int fixed_point_value = FX_convert(data[i]);
			// Ensure 16-bit representation of the address and data
			int address = i & 0xFFFF; // Mask to 16-bit address
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


	// Function to write data to file in "address_data" format
	void write_to_file3(const char* filename, uint32_t data[], int length) {
		FILE *file = fopen(filename, "w");
		if (file == NULL) {
			printf("Error: Unable to open file %s for writing.\n", filename);
			return;
		}

		for (int i = 0; i < length; i++) {
			int address = i & 0xFFFF; // Mask to 16-bit address
			
			fprintf(file, "%04x_%08x\n", address, data[i]);
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

	void Padding_Pool_0(float input_Pad_Pool[1280], float output_Pad_Pool[2568]){
		// write_to_file2("LDM_File.txt", input_Pad_Pool, 1280);
		loop_for_3_channel_pad_0:
		for (int c = 0; c < 8; c++){
			loop_for_channel_pad_0:
			for (int n = 0; n < 321; n++){
				if (n >= 321) output_Pad_Pool[321 * c + n]=0; else output_Pad_Pool[321 * c + n] = input_Pad_Pool[160 * c + n];
				// printf("output_Pad_Pool[%d] = input_Pad_Pool[%d] from PE %d, LDM depth = %d, Data = %.0f\n",321 * c + n,160 * c + n, (160 * c + n)%20,(160 * c + n)/20, input_Pad_Pool[160 * c + n]/0.015625);
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
				if((y%20)==0)
					printf("=======================================================================================================================\n");
				printf("PE %d\n",y%20);
				for (int j = 0; j < PoolSize; j++)
				{
					int pool_index = 321 * z + j + y * stride;
					float pool_value = input_MaxPooling[pool_index];
					
					printf("input_MaxPooling[%d], Data = %.0f\n",pool_index, input_MaxPooling[pool_index]/0.015625);
					if (pool_value > max) max=pool_value;
				}
				
				
				printf("\n\n\n");
				
				int out_index = 160 * z + index;
				output_MaxPooling[out_index]=max;
				index++;
			}
		}
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
			if((y%20)==0)
					printf("=======================================================================================================================\n");
				printf("PE %d\n",y%20);
			for (int j = 0; j < PoolSize; j++)
			{
				int pool_index = 162 * z + j + y * stride;
				float pool_value = input_MaxPooling[pool_index];
				printf("input_MaxPooling[%d], Data = %.0f\n",pool_index, input_MaxPooling[pool_index]/0.015625);
				if (pool_value > max) max=pool_value;
			}
			int out_index = 160 * z + index;
			output_MaxPooling[out_index]=max;
			index++;
		}
	}
}

void Padding_Pool_2(float input_Pad_Pool[1280], float output_Pad_Pool[1312]){
	write_to_file2("LDM_File.txt", input_Pad_Pool, 1280);
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
			if((y%20)==0)
					printf("=======================================================================================================================\n");
				printf("PE %d\n",y%20);
			for (int j = 0; j < PoolSize; j++)
			{
				int pool_index = 82 * z + j + y * stride;
				float pool_value = input_MaxPooling[pool_index];
				printf("input_MaxPooling[%d], Data = %.0f\n",pool_index, input_MaxPooling[pool_index]/0.015625);
				if (pool_value > max) max=pool_value;
			}
			int out_index = 80 * z + index;
			output_MaxPooling[out_index]=max;
			index++;
		}
	}
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
}

	int main() {
		// float input_Pad_Pool[1280];
		// float output_Pad_Pool[2568];
		// float output_MaxPooling[1280];


		// float input_Pad_Pool[1280];
		// float output_Pad_Pool[1296];
		// float output_MaxPooling[1280];

		// float input_Pad_Pool[1280];
		// float output_Pad_Pool[1312];
		// float output_MaxPooling[1280];

		float input_Pad_Pool[1280];
		float output_Pad_Pool[1344];
		float output_MaxPooling[1280];		
		
		// Initialize input_Pad_Pool with values starting from 0.015625, incrementing by 0.015625
		for (int i = 0; i < 1280; i++) {
			input_Pad_Pool[i] = 0.015625 * (i + 1);
		}

		// // Call Padding_Pool_0 function
		// Padding_Pool_0(input_Pad_Pool, output_Pad_Pool);

		// // Call Max_Pool1D_0 function
		// Max_Pool1D_0(output_Pad_Pool, output_MaxPooling);

		// // Call Padding_Pool_1 function
		// Padding_Pool_1(input_Pad_Pool, output_Pad_Pool);

		// // Call Max_Pool1D_1 function
		// Max_Pool1D_1(output_Pad_Pool, output_MaxPooling);

		// // Call Padding_Pool_0 function
		// Padding_Pool_2(input_Pad_Pool, output_Pad_Pool);

		// // Call Max_Pool1D_0 function
		// Max_Pool1D_2(output_Pad_Pool, output_MaxPooling);
		
		// Call Padding_Pool_0 function
		Padding_Pool_4(input_Pad_Pool, output_Pad_Pool);

		// Call Max_Pool1D_0 function
		Max_Pool1D_4(output_Pad_Pool, output_MaxPooling);
		
		// Display results from output_MaxPooling
		printf("Results of Max Pooling:\n");
		for (int i = 0; i < 1280; i++) {
			// printf("output_MaxPooling[%d] = %f\n", i, output_MaxPooling[i]);
		}

		write_to_file("Output_Conv.txt", output_MaxPooling, 1280);
		 // write_to_file2("LDM_File.txt", Input_Conv, 320);
		// int pad_ctx = 0, n_ctx = 7, y_ctx = 7, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 3, stride_ctx = 0, resCon_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 0;

		// // Call the function to concatenate inputs into a 28-bit output
		// uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, resCon_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
		
		// // Pass the address of result to write_to_file2
		// write_to_file3("CRAM_File.txt", &result, 1);
		
		// int pad_ctx = 1, n_ctx = 7, y_ctx = 7, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 3, stride_ctx = 0, resCon_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 0;

		// // Call the function to concatenate inputs into a 28-bit output
		// uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, resCon_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
		
		// Pass the address of result to write_to_file2
		// write_to_file3("CRAM_File.txt", &result, 1);
		
		// int pad_ctx = 1, n_ctx = 15, y_ctx = 3, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 3, stride_ctx = 0, resCon_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 0;

		// // Call the function to concatenate inputs into a 28-bit output
		// uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, resCon_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
		
		// // Pass the address of result to write_to_file2
		// write_to_file3("CRAM_File.txt", &result, 1);
		
		
		
		int pad_ctx = 1, n_ctx = 31, y_ctx = 1, k_ctx = 0, j_ctx = 0, alu_cfg_ctx = 3, stride_ctx = 0, resCon_ctx = 0, s_ldm_ctx = 0, d_ldm_ctx = 1, sa_ldm_ctx = 0;

		// Call the function to concatenate inputs into a 28-bit output
		uint32_t result = concatenate_to_32bit(pad_ctx, n_ctx, y_ctx, k_ctx, j_ctx, alu_cfg_ctx, stride_ctx, resCon_ctx, s_ldm_ctx, d_ldm_ctx, sa_ldm_ctx);
		
		// Pass the address of result to write_to_file2
		write_to_file3("CRAM_File.txt", &result, 1);
		return 0;
	}

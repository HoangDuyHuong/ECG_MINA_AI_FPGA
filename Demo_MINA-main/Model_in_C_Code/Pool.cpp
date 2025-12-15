#include <cmath>  // Include cmath for the round function
#include <cstdio>
#include <stdio.h>
#include <math.h>
#include <stdint.h>

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
void Max_Pool1D_4(float input_MaxPooling[2592], float output_MaxPooling[1280]){
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
}
void GlobalAveragePool1D(float input_GlobalAveragePool1D[1280],float output_GlobalAveragePool1D[32]){
	int hs = 0;
	for (int i = 0; i < 32; i++){
		float avg = 0;
		for (int j = 0; j < 40; j++){
			avg += input_GlobalAveragePool1D[40 * i + j];
		}
		output_GlobalAveragePool1D[hs] = avg / 40;
		hs++;
	}
}

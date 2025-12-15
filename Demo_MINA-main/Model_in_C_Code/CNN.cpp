#include "Conv.h"
#include "Pool.h"
#include "Dense.h"
#include <stdio.h>
#include <algorithm>
#include <string.h>


void CNN(float InModel[320],float &OutModel,float Weights[6457]){
	float OutPadConv0[324];
	float conv1d[1280];
	float re_lu[1280];
	float OutPadPool0[2568];
	float max_pooling1d[1280];
	float conv1d_1[320];
	float conv1d_2[320];
	float OutPadConv3[324];
	float conv1d_3[320];
	float OutPadConv4[328];
	float conv1d_4[320];
	float OutPadConv5[332];
	float conv1d_5[320];
	float re_lu_1[1280];
	float OutPadPool1[1296];
	float max_pooling1d_1[1280];
	float conv1d_6[320];
	float conv1d_7[320];
	float OutPadConv8[324];
	float conv1d_8[320];
	float OutPadConv9[328];
	float conv1d_9[320];
	float OutPadConv10[332];
	float conv1d_10[320];
	float re_lu_2[1280];
	float add[1280];
	float OutPadConv11[1296];
	float conv1d_11[1280];
	float re_lu_3[1280];
	float OutPadPool2[2576];
	float max_pooling1d_2[1280];
	float conv1d_12[320];
	float conv1d_13[320];
	float OutPadConv14[328];
	float conv1d_14[320];
	float OutPadConv15[336];
	float conv1d_15[320];
	float OutPadConv16[344];
	float conv1d_16[320];
	float re_lu_4[1280];
	float OutPadPool3[1312];
	float max_pooling1d_3[1280];
	float conv1d_17[320];
	float conv1d_18[320];
	float OutPadConv19[328];
	float conv1d_19[320];
	float OutPadConv20[336];
	float conv1d_20[320];
	float OutPadConv21[344];
	float conv1d_21[320];
	float re_lu_5[1280];
	float add_1[1280];
	float OutPadConv22[1280];
	float conv1d_22[1280];
	float re_lu_6[1280];
	float OutPadPool4[2592];
	float max_pooling1d_4[1280];
	float conv1d_23[320];
	float conv1d_24[320];
	float OutPadConv25[336];
	float conv1d_25[320];
	float OutPadConv26[352];
	float conv1d_26[320];
	float OutPadConv27[368];
	float conv1d_27[320];
	float re_lu_7[1280];
	float OutPadPool5[1344];
	float max_pooling1d_5[1280];
	float conv1d_28[320];
	float conv1d_29[320];
	float OutPadConv30[336];
	float conv1d_30[320];
	float OutPadConv31[352];
	float conv1d_31[320];
	float OutPadConv32[368];
	float conv1d_32[320];
	float re_lu_8[1280];
	float add_2[1280];
	float global_average_pooling1d[32];
	float concatenate[1280];
	float concatenate_1[1280];
	float concatenate_2[1280];
	float concatenate_3[1280];
	float concatenate_4[1280];
	float concatenate_5[1280];
	Padding_Conv1D_0(&InModel[0],OutPadConv0);
	Conv1D_0(OutPadConv0,conv1d,&Weights[56],&Weights[0]);
	Activation0(conv1d,re_lu);
	Padding_Pool_0(re_lu,OutPadPool0);
	Max_Pool1D_0(OutPadPool0,max_pooling1d);
	
	Conv1D_2(max_pooling1d,conv1d_2,&Weights[98],&Weights[82]);
	Conv1D_1(re_lu,conv1d_1,&Weights[80],&Weights[64]);
	Padding_Conv1D_3(conv1d_1,OutPadConv3);
	Conv1D_3(OutPadConv3,conv1d_3,&Weights[112],&Weights[100]);
	Padding_Conv1D_4(conv1d_1,OutPadConv4);
	Conv1D_4(OutPadConv4,conv1d_4,&Weights[134],&Weights[114]);
	Padding_Conv1D_5(conv1d_1,OutPadConv5);
	Conv1D_5(OutPadConv5,conv1d_5,&Weights[164],&Weights[136]);
	for (int k = 0; k < 320; k++)
	{
		concatenate[k] = conv1d_2[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate[320 + k] = conv1d_3[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate[2 * 320 + k] = conv1d_4[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate[3 * 320 + k] = conv1d_5[k];
	}
	Activation1(concatenate,re_lu_1);
	Padding_Pool_1(re_lu_1,OutPadPool1);
	Max_Pool1D_1(OutPadPool1,max_pooling1d_1);
	Conv1D_7(max_pooling1d_1,conv1d_7,&Weights[200],&Weights[184]);
	
	Conv1D_6(re_lu_1,conv1d_6,&Weights[182],&Weights[166]);
	
	Padding_Conv1D_8(conv1d_6,OutPadConv8);
	Conv1D_8(OutPadConv8,conv1d_8,&Weights[214],&Weights[202]);
	Padding_Conv1D_9(conv1d_6,OutPadConv9);
	Conv1D_9(OutPadConv9,conv1d_9,&Weights[236],&Weights[216]);
	Padding_Conv1D_10(conv1d_6,OutPadConv10);
	Conv1D_10(OutPadConv10,conv1d_10,&Weights[266],&Weights[238]);
	for (int k = 0; k < 320; k++)
	{
		concatenate_1[k] = conv1d_7[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_1[320 + k] = conv1d_8[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_1[2 * 320 + k] = conv1d_9[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_1[3 * 320 + k] = conv1d_10[k];
	}
	Activation2(concatenate_1,re_lu_2);
	Add2D_0(re_lu_2,re_lu,add);
	Padding_Conv1D_11(add,OutPadConv11);
	Conv1D_11(OutPadConv11,conv1d_11,&Weights[908],&Weights[268]);
	Activation3(conv1d_11,re_lu_3);
	Padding_Pool_2(re_lu_3,OutPadPool2);
	Max_Pool1D_2(OutPadPool2,max_pooling1d_2);
	Conv1D_13(max_pooling1d_2,conv1d_13,&Weights[1056],&Weights[992]);
	
	Conv1D_12(re_lu_3,conv1d_12,&Weights[988],&Weights[924]);
	
	Padding_Conv1D_14(conv1d_12,OutPadConv14);
	Conv1D_14(OutPadConv14,conv1d_14,&Weights[1108],&Weights[1060]);
	Padding_Conv1D_15(conv1d_12,OutPadConv15);
	Conv1D_15(OutPadConv15,conv1d_15,&Weights[1192],&Weights[1112]);
	Padding_Conv1D_16(conv1d_12,OutPadConv16);
	Conv1D_16(OutPadConv16,conv1d_16,&Weights[1308],&Weights[1196]);
	for (int k = 0; k < 320; k++)
	{
		concatenate_2[k] = conv1d_13[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_2[320 + k] = conv1d_14[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_2[2 * 320 + k] = conv1d_15[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_2[3 * 320 + k] = conv1d_16[k];
	}
	Activation4(concatenate_2,re_lu_4);//
	Padding_Pool_3(re_lu_4,OutPadPool3);
	Max_Pool1D_3(OutPadPool3,max_pooling1d_3);
	
	Conv1D_18(max_pooling1d_3,conv1d_18,&Weights[1444],&Weights[1380]);
	
	Conv1D_17(re_lu_4,conv1d_17,&Weights[1376],&Weights[1312]);
	
	Padding_Conv1D_19(conv1d_17,OutPadConv19);
	Conv1D_19(OutPadConv19,conv1d_19,&Weights[1496],&Weights[1448]);
	Padding_Conv1D_20(conv1d_17,OutPadConv20);
	Conv1D_20(OutPadConv20,conv1d_20,&Weights[1580],&Weights[1500]);
	Padding_Conv1D_21(conv1d_17,OutPadConv21);
	Conv1D_21(OutPadConv21,conv1d_21,&Weights[1696],&Weights[1584]);
	for (int k = 0; k < 320; k++)
	{
		concatenate_3[k] = conv1d_18[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_3[320 + k] = conv1d_19[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_3[2 * 320 + k] = conv1d_20[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_3[3 * 320 + k] = conv1d_21[k];
	}
	Activation5(concatenate_3,re_lu_5);
	Add2D_1(re_lu_5,re_lu_3,add_1);
	Padding_Conv1D_22(add_1,OutPadConv22);
	Conv1D_22(OutPadConv22,conv1d_22,&Weights[3236],&Weights[1700]);
	Activation6(conv1d_22,re_lu_6);
	Padding_Pool_4(re_lu_6,OutPadPool4);
	Max_Pool1D_4(OutPadPool4,max_pooling1d_4);
	Conv1D_24(max_pooling1d_4,conv1d_24,&Weights[3788],&Weights[3532]);
	
	Conv1D_23(re_lu_6,conv1d_23,&Weights[3524],&Weights[3268]);
	
	Padding_Conv1D_25(conv1d_23,OutPadConv25);
	Conv1D_25(OutPadConv25,conv1d_25,&Weights[3988],&Weights[3796]);
	Padding_Conv1D_26(conv1d_23,OutPadConv26);
	Conv1D_26(OutPadConv26,conv1d_26,&Weights[4316],&Weights[3996]);
	Padding_Conv1D_27(conv1d_23,OutPadConv27);
	Conv1D_27(OutPadConv27,conv1d_27,&Weights[4772],&Weights[4324]);
	for (int k = 0; k < 320; k++)
	{
		concatenate_4[k] = conv1d_24[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_4[320 + k] = conv1d_25[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_4[2 * 320 + k] = conv1d_26[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_4[3 * 320 + k] = conv1d_27[k];
	}
	Activation7(concatenate_4,re_lu_7);
	Padding_Pool_5(re_lu_7,OutPadPool5);
	Max_Pool1D_5(OutPadPool5,max_pooling1d_5);
	Conv1D_29(max_pooling1d_5,conv1d_29,&Weights[5300],&Weights[5044]);
	
	Conv1D_28(re_lu_7,conv1d_28,&Weights[5036],&Weights[4780]);
	
	Padding_Conv1D_30(conv1d_28,OutPadConv30);
	Conv1D_30(OutPadConv30,conv1d_30,&Weights[5500],&Weights[5308]);
	Padding_Conv1D_31(conv1d_28,OutPadConv31);
	Conv1D_31(OutPadConv31,conv1d_31,&Weights[5828],&Weights[5508]);
	Padding_Conv1D_32(conv1d_28,OutPadConv32);
	Conv1D_32(OutPadConv32,conv1d_32,&Weights[6284],&Weights[5836]);
	for (int k = 0; k < 320; k++)
	{
		concatenate_5[k] = conv1d_29[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_5[320 + k] = conv1d_30[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_5[2 * 320 + k] = conv1d_31[k];
	}
	for (int k = 0; k < 320; k++)
	{
		concatenate_5[3 * 320 + k] = conv1d_32[k];
	}
	Activation8(concatenate_5,re_lu_8);
	Add2D_2(re_lu_8,re_lu_6,add_2);
	GlobalAveragePool1D(add_2,global_average_pooling1d);
	Dense_0(global_average_pooling1d,OutModel,&Weights[6452],&Weights[6292]);
}

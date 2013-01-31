#include<iostream>
#include<fstream>
#include<strstream>
#include <cuda.h>
#include <math.h>
#include<stdio.h>
#include<stdlib.h>

using namespace std;

int min2(int,int);
int min1(int,int,int);



__global__ void initialisation(int* G1, int* G2, int* D1, int* I2, int ge, int gi, int n)
{
    	int j = threadIdx.x;
    	if(j>0)
    	{
    		G1[j]=gi+ge*j;
       		D1[j]=G1[j]+ge;
	}
        if(j==0)
        {
		G1[0]=0;
    		G2[0]=gi+ge*n;
               	I2[0]=G2[0]+ge;
     	}

}

__global__ void copy_array(float* A, float* B)
{
    int i = threadIdx.x;
    B[i] = A[i];
}

int main(int argc, char** argv)
{
	int i,j,n;
	
	char buffer1[2048];								//--- taking input from file
	char buffer2[2048];								//--- n,s1,s2 are the corresponding three lines of input
	char buffer3[2048];
	istrstream str1(buffer1, 2048);
	istrstream str2(buffer2, 2048);
	istrstream str3(buffer3, 2048);
	ifstream indata("rand-1024-in.txt");		
	indata.getline(buffer1, 2048);
	indata.getline(buffer2, 2048);
	indata.getline(buffer3, 2048);
	str1>>n;

	size_t size = (n) * sizeof(char);
	size_t size1 = (n)*sizeof(int);

	char* h_s1 = (char*)malloc(size);
	char* h_s2 = (char*)malloc(size);

	for(i=0;i<n;i++)
	{
		str2>>h_s1[i];
		str3>>h_s2[i];
	}												//--- end of input
		
	
	int* h_D1 = (int*)malloc(size1);
	int* h_D2 = (int*)malloc(size1);
	int* h_G1 = (int*)malloc(size1);
	int* h_G2 = (int*)malloc(size1);
	int* h_I1 = (int*)malloc(size1);
	int* h_I2 = (int*)malloc(size1);
	int* h_u = (int*)malloc(size1);
	int* h_v = (int*)malloc(size1);
	int* h_se = (int*)malloc(size1);


//	int h_D1[n], h_D2[n],h_G1[n], h_G2[n],h_I1[n+1],h_I2[n+1],h_u[n],h_v[n],h_se[n];	
	int gi,ge,s,cost;
	gi=2;ge=1;

	int *d_D1, *d_D2;
    	cudaMalloc(&d_D1, size1);
	cudaMalloc(&d_D2, size1);
    	int *d_G1, *d_G2;
    	cudaMalloc(&d_G1, size1);
	cudaMalloc(&d_G2, size1);
    	int *d_I1, *d_I2;
    	cudaMalloc(&d_I1, size1);
	cudaMalloc(&d_I2, size1);
    	int *d_u, *d_v, *d_se;
    	cudaMalloc(&d_u, size1);
	cudaMalloc(&d_v, size1);
	cudaMalloc(&d_se, size1);
    
/*	char *d_s1, *d_s2;
	cudaMalloc(&d_s1, size);
	cudaMalloc(&d_s2, size);

    	cudaMemcpy(d_s1, h_s1, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_s2, h_s2, size, cudaMemcpyHostToDevice);
*/
	
//	d_G1[0]=0;
	initialisation<<<1, n>>>(d_G1, d_G2, d_D1, d_I2, gi, ge, n);



/*	h_G1[0]=0;										
		for(j=0;j<n;j++)
		{
			if(j>0)
			{
				h_G1[j]=gi+ge*j;
				h_D1[j]=h_G1[j]+ge;
			}
			if(j==0)
			{
				h_G2[0]=gi+ge*i;
				h_I2[0]=h_G2[0]+ge;
			}
		}
*/


	cudaMemcpy(h_D1, d_D1, size1, cudaMemcpyDeviceToHost);
    	cudaMemcpy(h_G1, d_G1, size1, cudaMemcpyDeviceToHost);
   	cudaMemcpy(h_G2, d_G2, size1, cudaMemcpyDeviceToHost);
	cudaMemcpy(h_I2, d_I2, size1, cudaMemcpyDeviceToHost);	
	
	for(i=1;i<n;i++)								//--- calculation of D,I,G
	{
		for(j=1;j<n;j++)
		{
			
			if(i>0 && j>0)
			{
				h_D2[j]=min(h_D1[j],h_G1[j]+gi)+ge;
				
				if(h_s1[i]!=h_s2[j])
					s=1;
				else
					s=0;
				
				h_u[j] = min(h_D2[j],h_G1[j-1]+s);
				
				h_v[j] = h_u[j]+gi-j*ge;
				
				h_G2[j]=min(h_u[j],h_I2[j]);
				
				h_se[j]=h_v[j];
				for(int k=1; k<=j;k++)
				{
					if(h_se[j] > h_v[k])
						h_se[j]=h_v[k];
				}
				
				h_I2[j+1]=h_se[j]+(j+1)*ge;
				if(j==1)
					h_I2[1]=min(h_I2[0],h_G2[0]+gi) + ge;
		
				h_G2[j]=min1(h_D2[j],h_I2[j],h_G1[j-1]+s);
			}
		}
	
	
	

		for(int t=0;t<n;t++)
		{
			h_D1[t]=h_D2[t];
			h_I1[t]=h_I2[t];
			h_G1[t]=h_G2[t];
		}
	
	}													//--- end of loop for calculation
	
	cost=min1(h_D2[n-1],h_I2[n-1],h_G2[n-1]);			//--- allignment cost
	
	cout<<"Optimal Allignment cost: "<<cost<<endl;
	
	return 0;
}
int min2(int a,int b)
{
	if(a>b)
		return b;
	else
		return a;
}

int min1(int a,int b,int c)
{
	int m=a;
    if(m>b)
		m=b;
    if(m>c)
		m=c;
    return m;
}

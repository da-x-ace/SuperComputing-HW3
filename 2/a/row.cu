#include<iostream>
#include <cuda.h>
#include <math.h>
#include<stdio.h>
#include<stdlib.h>
#include <sys/types.h>
#include <time.h>



using namespace std;

__device__ int min2(int a, int b)
{
	int m = a;
	if(m > b)
		m=b;
	return m;
}
__device__ int min1(int a,int b,int c)
{
	int m=a;
    if(m>b)
		m=b;
    if(m>c)
		m=c;
    return m;
}	

int min3(int a,int b,int c)
{
	int m=a;
    if(m>b)
		m=b;
    if(m>c)
		m=c;
    return m;
}	

void swapPointers(int **prev,int **current)
{
     int * temp = *prev;
     *prev      = *current;
     *current   = temp;
}



__global__ void main_work(char* s1, char *s2, int* G1, int* G2, int* D1, int* D2, int* I1, int* I2, int* u, int* v, int* se, int ge, int gi, int n, int i, int numElements)
{
	int j =   blockIdx.x * blockDim.x + threadIdx.x;
	int s=0;
	
	if( j > numElements ) return ;
	
	__syncthreads();
			if(j==0 && i>0)
			{
				G2[0]=gi+ge*i;
				I2[0]=G2[0]+ge;
			}
			if(j>0 && i == 0)
			{
				G1[j]=gi+ge*j;
				D1[j]=G1[j]+ge;
			}
			if(i>0 && j>0)
			{
				D2[j]=min2(D1[j],G1[j]+gi)+ge;
				__syncthreads();
				if(s1[i]!=s2[j])
					s=1;
				else
					s=0;
				__syncthreads();
				u[j] = min2(D2[j],G1[j-1]+s);
				__syncthreads();
				v[j] = u[j]+gi-j*ge;
				__syncthreads();
				se[j]=v[j];
				__syncthreads();
				for(int k=1; k<=j;k++)
				{
					if(se[j] > v[k])
						se[j]=v[k];
				}
				__syncthreads();
				I2[j+1]=se[j]+(j+1)*ge;
				__syncthreads();
				if(j==1)
					I2[1]=min2(I2[0],G2[0]+gi) + ge;
				__syncthreads();
				G2[j]=min1(D2[j],I2[j],G1[j-1]+s);
			}
}


int main(int argc, char** argv)
{
	int i,n;
	time_t t0, t1;
    clock_t c0,c1;
	char skip;

	scanf("%d",&n);
	printf("%d \n",n);
	while(1)
	{
		scanf("%c",&skip);
		if(skip == '\n')
			break;
	}
	size_t size = (n+1) * sizeof(char);
	size_t size1 = (n+1)*sizeof(int);

	char* h_s1 = (char*)malloc(size);
	char* h_s2 = (char*)malloc(size);
	
	for(i=1; i<=n; i++)
	{
		scanf("%c",&h_s1[i]);
	}
	while(1)
	{
		scanf("%c",&skip);
		if(skip == '\n')
			break;
	}
	for(i=1; i<=n; i++)
	{
		scanf("%c",&h_s2[i]);
	}
	

	t0=time(NULL);
        c0=clock();

        printf ("\tbegin (wall):            %ld\n", (long) t0);
        printf ("\tbegin (CPU):             %d\n", (int) c0);
	
	int* h_D1 = (int*)malloc(size1);
	int* h_D2 = (int*)malloc(size1);
	int* h_G1 = (int*)malloc(size1);
	int* h_G2 = (int*)malloc(size1);
	int* h_I1 = (int*)malloc(size1);
	int* h_I2 = (int*)malloc(size1);
	
	int gi,ge,cost;
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
	
	char *d_s1, *d_s2;
	cudaMalloc(&d_s1, size);
	cudaMalloc(&d_s2, size);

    cudaMemcpy(d_s1, h_s1, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_s2, h_s2, size, cudaMemcpyHostToDevice);
	
	h_G1[0]=0;										
	cudaMemcpy(d_G1, h_G1, size1, cudaMemcpyHostToDevice);
	
	int num_threads;
	int num_blocks;
	int numElements;
	
		numElements = n+1;
		if( numElements <= 256) {
		 num_threads = numElements;
		 num_blocks =1 ;
		 }
		 else
		 {
		   num_threads = 256 ;
		   num_blocks = numElements/num_threads + ((numElements/num_threads == 0) ? 0 : 1) ;
		 }

	for(i=0;i<=n;i++)								
	{
	
		
		main_work<<<num_blocks,num_threads>>>(d_s1, d_s2, d_G1, d_G2, d_D1, d_D2, d_I1, d_I2, d_u, d_v, d_se, ge, gi, n, i, numElements);
		
		if(i > 0)
		{
			swapPointers(&d_D1,&d_D2);
			swapPointers(&d_I1,&d_I2);
			swapPointers(&d_G1,&d_G2);
		}

	}													//--- end of loop for calculation
	
	cudaMemcpy(h_D1, d_D1, size1, cudaMemcpyDeviceToHost);
	cudaMemcpy(h_D2, d_D2, size1, cudaMemcpyDeviceToHost);
    	cudaMemcpy(h_G1, d_G1, size1, cudaMemcpyDeviceToHost);
   	cudaMemcpy(h_G2, d_G2, size1, cudaMemcpyDeviceToHost);
	cudaMemcpy(h_I1, d_I1, size1, cudaMemcpyDeviceToHost);
	cudaMemcpy(h_I2, d_I2, size1, cudaMemcpyDeviceToHost);
	
	cost=min3(h_D1[n],h_I1[n],h_G1[n]);			//--- allignment cost
	
	cout<<"Optimal Allignment cost: "<<cost<<endl;
	
	t1=time(NULL);
        c1=clock();
        printf ("\telapsed wall clock time: %ld\n", (long) (t1 - t0));
        printf ("\telapsed CPU time:        %f\n", (float) (c1 - c0)/CLOCKS_PER_SEC);
	
	cudaFree(d_D1);
	cudaFree(d_D2);
	cudaFree(d_I1);
	cudaFree(d_I2);
	cudaFree(d_G1);
	cudaFree(d_G2);
	cudaFree(d_u);
	cudaFree(d_v);
	cudaFree(d_se);
	
	free(h_s1);
	free(h_s2);
	return 0;
}


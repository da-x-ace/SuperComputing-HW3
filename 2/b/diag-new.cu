#include<iostream>
#include <cuda.h>
#include <math.h>
#include<stdio.h>
#include<stdlib.h>
#include <sys/types.h>
#include <time.h>



using namespace std;

__device__ int mymin(int a, int b)
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

int min2(int a,int b,int c)
{
	int m=a;
    if(m>b)
		m=b;
    if(m>c)
		m=c;
    return m;
}	

void swapDiagnolPointers(int **prev,int **current)
{
     int * temp = *prev;
     *prev      = *current;
     *current   = temp;
}

void swapDiagnolPointersForG(int **prevprev, int **prev,int **current)
{
     int * temp = *prevprev;
	 *prevprev = *prev;
     *prev      = *current;
     *current   = temp;
}

__global__ void less_than_n(int k,int numElements,int * D1,int * D2,int * I1,int * I2,int * G0,int *G1,int * G2,char *s1,char *s2, int gi, int ge)
		{
			int i =   blockIdx.x * blockDim.x + threadIdx.x;
			int s =0;
			
			if( i > numElements ) return ;
			
			if(i == 0)
				{
						G2[i]=gi+ge*k;
						I2[i]=G2[i]+ge;
				}
				if(i == k)
				{
						G2[i]=gi+ge*k;
						D2[i]=G2[i]+ge;
				}
				if( i>0 && i<k)
				{
					D2[i]=min(D1[i],G1[i]+gi)+ge;
					I2[i]=min(I1[i-1],G1[i-1]+gi)+ge;
					if(s1[i]!=s2[k-i])
						s=1;
					else
						s=0;
					G2[i]=min1(D2[i],I2[i],G0[i-1]+s);	
				}	
		}

__global__ void greater_than_n(int k,int numElements,int * D1,int * D2,int * I1,int * I2,int * G0,int *G1,int * G2,char *s1,char *s2,int n, int gi, int ge)
		{
			int i =   blockIdx.x * blockDim.x + threadIdx.x;
			int s =0;
			
			if( i > numElements ) return ;
	
				D2[i]=min(D1[i+1],G1[i+1]+gi)+ge;
				I2[i]=min(I1[i],G1[i]+gi)+ge;
				if(s1[i+(k-n)]!=s2[k-(i+k-n)])
					s=1;
				else
					s=0;
				if((k-n)==1)
					G2[i]=min1(D2[i],I2[i],G0[i]+s);
				else
					G2[i]=min1(D2[i],I2[i],G0[i+1]+s);
		}

int main(int argc, char** argv)
{
	int i,j,n,k,l;
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
	

/*	t0=time(NULL);
        c0=clock();

        printf ("\tbegin (wall):            %ld\n", (long) t0);
        printf ("\tbegin (CPU):             %d\n", (int) c0);
*/	
	int* h_D0 = (int*)malloc(size1);
	int* h_D1 = (int*)malloc(size1);
	int* h_D2 = (int*)malloc(size1);
	int* h_G0 = (int*)malloc(size1);
	int* h_G1 = (int*)malloc(size1);
	int* h_G2 = (int*)malloc(size1);
	int* h_I0 = (int*)malloc(size1);
	int* h_I1 = (int*)malloc(size1);
	int* h_I2 = (int*)malloc(size1);
	
//	int D0[n+1],D1[n+1],D2[n+1],G0[n+1],G1[n+1],G2[n+1],I0[n+1],I1[n+1],I2[n+1];				//--- declaration of functions
	int gi,ge,s,cost;
	gi=2;ge=1;

		int *d_D0, *d_D1, *d_D2;
		cudaMalloc(&d_D0, size1);
    	cudaMalloc(&d_D1, size1);
		cudaMalloc(&d_D2, size1);
    	int *d_G0, *d_G1, *d_G2;
		cudaMalloc(&d_G0, size1);
    	cudaMalloc(&d_G1, size1);
		cudaMalloc(&d_G2, size1);
    	int *d_I0, *d_I1, *d_I2;
		cudaMalloc(&d_I0, size1);
    	cudaMalloc(&d_I1, size1);
		cudaMalloc(&d_I2, size1);
	
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
	
	for(k=1;k<=2*n;k++)
	{
		if(k <=n)
		{	
			 numElements = k+1;
			if( numElements <= 256) {
			 num_threads = numElements;
			 num_blocks =1 ;
			 }
			 else
			 {
			   num_threads = 256 ;
			   num_blocks = numElements/num_threads + ((numElements/num_threads == 0) ? 0 : 1) ;
			 }
			 
			 less_than_n<<<num_blocks,num_threads>>>(  k,  numElements,   d_D1, d_D2,  d_I1,d_I2,  d_G0, d_G1,  d_G2, d_s1, d_s2, gi, ge);
		}
		if(k > n)
		{
			numElements = n-(k-n)+1;
			if( numElements <= 256) {
			 num_threads = numElements;
			 num_blocks =1 ;
			 }
			 else
			 {
			   num_threads = 256 ;
			   num_blocks = numElements/num_threads + ((numElements/num_threads == 0) ? 0 : 1) ;
			 }
			 
			 greater_than_n<<<num_blocks,num_threads>>>(  k,  numElements,   d_D1, d_D2,  d_I1,d_I2,  d_G0, d_G1,  d_G2, d_s1, d_s2, n, gi, ge);
		}

		swapDiagnolPointers(&d_D1,&d_D2);
		swapDiagnolPointers(&d_I1,&d_I2);
		swapDiagnolPointersForG(&d_G0,&d_G1, &d_G2);
	}
	
	cudaMemcpy(h_D2, d_D2, size1, cudaMemcpyDeviceToHost);
	
    cudaMemcpy(h_G2, d_G2, size1, cudaMemcpyDeviceToHost);
   	
	cudaMemcpy(h_I2, d_I2, size1, cudaMemcpyDeviceToHost);

	cudaMemcpy(h_D1, d_D1, size1, cudaMemcpyDeviceToHost);
	
    cudaMemcpy(h_G1, d_G1, size1, cudaMemcpyDeviceToHost);
   	
	cudaMemcpy(h_I1, d_I1, size1, cudaMemcpyDeviceToHost);

	

	


	
	cost=min2(h_D1[0],h_I1[0],h_G1[0]);			//--- allignment cost
	
	cout<<"Optimal Allignment cost: "<<cost<<endl;
/*	
	t1=time(NULL);
        c1=clock();
        printf ("\telapsed wall clock time: %ld\n", (long) (t1 - t0));
        printf ("\telapsed CPU time:        %f\n", (float) (c1 - c0)/CLOCKS_PER_SEC);

	cudaFree(d_G0);
	cudaFree(d_G1);
	cudaFree(d_G2);
	cudaFree(d_D0);
	cudaFree(d_D1);
	cudaFree(d_D2);
	cudaFree(d_I0);
	cudaFree(d_I1);
	cudaFree(d_I2);
	cudaFree(d_s1);
	cudaFree(d_s2);
	
	free(h_s1);
	free(h_s2);
	free(h_G1);
	free(h_G2);
	free(h_D1);
	free(h_D2);
	free(h_I1);
	free(h_I2);
*/
	return 0;
}





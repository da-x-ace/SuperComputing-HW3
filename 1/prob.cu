#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<cuda.h>


__global__ void copy_array(float* A, float* B)
{
//    int i = threadIdx.x;
	int i = blockIdx.x * blockDim.x + threadIdx.x;

    B[i] = A[i];
}


__global__ void prefix_sum_extend(float* B, int t, int s)
{
//    int i = threadIdx.x;
    int i = blockIdx.x * blockDim.x + threadIdx.x;

	if(i != 0)
	{	
		if(B[s+(2*i)-1] > B[s+(2*i)])
			B[t+i] = B[s+(2*i)];
		else
			B[t+i] = B[s+(2*i)-1];
	}
}

__global__ void prefix_sum_drop(float* B, float* C, int t, int s)
{
//    int i = threadIdx.x;
  int i = blockIdx.x * blockDim.x + threadIdx.x;

	  if( i!= 0)
        {
            if(i==1)
                C[t+i]=B[t+i];
            else if(i%2==0)
                    C[t+i]=C[s+i/2];
                else
					if(C[s+((i-1)/2)] > B[t+i])
						C[t+i]=B[t+i];
					else
						C[t+i]=C[s+((i-1)/2)];
        }

}


int main(int argc, char** argv)
{
	int k;
    scanf("%d",&k);
    int i,m,t,s,h;
    int N = (int)pow(2.0,k);
    size_t size = (N+1) * sizeof(float);
    size_t size1 = (2*N)* sizeof(float);
    
    float* h_A = (float*)malloc(size);
    float* h_S = (float*)malloc(size);
    float* h_B = (float*)malloc(size1);
    float* h_C = (float*)malloc(size1);
    
    
    for(i=1;i<=N;i++)
        h_A[i]=rand()%10+1;
    
/*    for (int i=1; i<=N; i++)
         printf("%f ",h_A[i]);
    printf("\n");
*/
    float* d_A;
    cudaMalloc(&d_A, size);
    float* d_S;
    cudaMalloc(&d_S, size);
    float* d_B;
    cudaMalloc(&d_B, size1);
    float* d_C;
    cudaMalloc(&d_C, size1);
    
    cudaMemcpy(d_A, h_A, size, cudaMemcpyHostToDevice);
    int block_size, n_blocks; 
	if(N >=256)	
	{
		block_size = 256;
		n_blocks = N/block_size + (N%block_size == 0 ? 0:1);
	}else{
		block_size =1;
		n_blocks = N+1;
	}
//    copy_array<<<1, N+1>>>(d_A, d_B);
  copy_array<<<n_blocks, block_size>>>(d_A, d_B);
     
 
    m = N;
    t=0;
    
    for(h=1;h<=k;h++)
    {
        s=t;
        t=t+m;
        m=m/2;
	if(m >=256)
        {
                block_size = 256;
                n_blocks = m/block_size + (m%block_size == 0 ? 0:1);
        }else{
                block_size =1;
                n_blocks = m+1;
        }

//        prefix_sum_extend<<<1, m+1>>>(d_B, t, s);
	 prefix_sum_extend<<<n_blocks, block_size>>>(d_B, t, s);


    }

    for(h=k;h>=0;h--)
    {
	if(m >=256)
        {
                block_size = 256;                                                      
                n_blocks = m/block_size + (m%block_size == 0 ? 0:1);                   
        }else{
                block_size =1;
                n_blocks = m+1;
        }

//        prefix_sum_drop<<<1, m+1>>>(d_B, d_C, t, s);
	prefix_sum_drop<<<n_blocks, block_size>>>(d_B, d_C, t, s);
        m=2*m;
        s=t;
        t=t-m;
    }
    
	if(N >=256)
        {
                block_size = 256;
                n_blocks = N/block_size + (N%block_size == 0 ? 0:1);
        }else{
                block_size =1;
                n_blocks = N+1;
        }

//    copy_array<<<1, N+1>>>(d_C, d_S);
  copy_array<<<n_blocks, block_size>>>(d_C, d_S);  
    cudaMemcpy(h_B, d_B, size1, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_C, d_C, size1, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_S, d_S, size, cudaMemcpyDeviceToHost);
    
	if(N < 256)
	{
    for (int i=1; i<=N; i++) 
        printf("%f ",h_S[i]);
    printf("\n");
	}
    cudaFree(d_A);
    cudaFree(d_S);
    cudaFree(d_B);
    cudaFree(d_C);
}



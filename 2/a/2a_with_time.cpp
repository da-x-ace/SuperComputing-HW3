#include<iostream>
#include<stdlib.h>

#include<math.h>
#include <sys/timeb.h>
#include <sys/types.h>
#include <time.h>
using namespace std;

int min(int,int);
int min1(int,int,int);

int main()
{
	int i,j,n;
	time_t t0, t1;
        clock_t c0,c1;
        
	/*char buffer1[2048];								//--- taking input from file
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
*/

char skip;

	scanf("%d",&n);
	printf("%d \n",n);
	while(1)
	{
		scanf("%c",&skip);
		if(skip == '\n')
			break;
	}
	char* s1 = new char[n];
	char* s2 = new char[n];
	
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
												//--- end of input
	
/*	
	cout<<"value of n: "<<n<<endl<<endl;			//--- printing values of input
	cout<<"string1: ";
	for(i=0;i<n;i++)
	{
		cout<<s1[i];
	}
	cout<<endl<<endl<<"string2: ";
	for(i=0;i<n;i++)
	{
		cout<<s2[i];
	}
	cout<<endl<<endl;								//--- printing of i/p ends
*/
	
	t0=time(NULL);
        c0=clock();

        printf ("\tbegin (wall):            %ld\n", (long) t0);
        printf ("\tbegin (CPU):             %d\n", (int) c0);
        
        
	int D1[n], D2[n],G1[n], G2[n],I1[n],I2[n],u[n],v[n],se[n];	//--- declaration of functions
	int gi,ge,s,cost;
	gi=2;ge=1;

	G1[0]=0;										//--- initialization
	
									//--- calculation of D,I,G
/*
		for(j=0;j<n;j++)
		{
			if(j>0)
			{
				G1[j]=gi+ge*j;
				D1[j]=G1[j]+ge;
			}
			if(j==0)
			{
				G2[0]=gi+ge*1;
				I2[0]=G2[0]+ge;
			}
		}
*/
	
	for(i=0;i<=n;i++)								//--- calculation of D,I,G
	{
		for(j=0;j<=n;j++)
		{
			
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
				D2[j]=min(D1[j],G1[j]+gi)+ge;
				
				if(s1[i]!=s2[j])
					s=1;
				else
					s=0;
				
				u[j] = min(D2[j],G1[j-1]+s);
				
				v[j] = u[j]+gi-j*ge;
				
//				G2[j]=min(u[j],I2[j]);
				
				se[j]=v[j];
				for(int k=1; k<=j;k++)
				{
					if(se[j] > v[k])
						se[j]=v[k];
				}
				
				I2[j+1]=se[j]+(j+1)*ge;
				if(j==1)
					I2[1]=min(I2[0],G2[0]+gi) + ge;
		
				G2[j]=min1(D2[j],I2[j],G1[j-1]+s);
			}
		}
		if(i > 0)
		{
			for(int t=0;t<=n;t++)
			{
				D1[t]=D2[t];
				I1[t]=I2[t];
				G1[t]=G2[t];
			}
		}
	}						//--- end of loop for calculation
	
	cost=min1(D1[n],I1[n],G1[n]);			//--- allignment cost
	
	cout<<"Optimal Allignment cost: "<<cost<<endl;
	
	t1=time(NULL);
        c1=clock();
        printf ("\telapsed wall clock time: %ld\n", (long) (t1 - t0));
        printf ("\telapsed CPU time:        %f\n", (float) (c1 - c0)/CLOCKS_PER_SEC);
	delete[] s1;
	delete[] s2;
	return 0;
}

int min(int a,int b)
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

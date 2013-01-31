#include<iostream>
#include<fstream.h>
#include<strstream.h>
using namespace std;

int min(int,int);
int min1(int,int,int);

int main()
{
	int i,j,n,k,l;
	
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
	char* s1 = new char[n+1];
	char* s2 = new char[n+1];
	for(i=1;i<=n;i++)
	{
		str2>>s1[i];
		str3>>s2[i];
	}												//--- end of input
	
	
	/*cout<<"value of n: "<<n<<endl<<endl;			//--- printing values of input
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
	
	int D0[n+1],D1[n+1],D2[n+1],G0[n+1],G1[n+1],G2[n+1],I0[n+1],I1[n+1],I2[n+1],u[n+1],v[n+1],se[n+1];				//--- declaration of functions
	int gi,ge,s,cost;
	gi=2;ge=1;

	G1[0]=0;										//--- initialization

	


	for(k=0;k<(2*n+1);k++)
	{
		l=0;
		for(j=0;j<=k;j++)								//--- calculation of D,I,G
		{
			for(i=0;i<=n;i++)
			{
				if(i+j==k)
				{
					if(i==0 && j>0)
					{
						G2[l]=gi+ge*j;
						D2[l]=G2[l]+ge;
					}
					if(i>0 && j==0)
					{
						G2[l]=gi+ge*i;
						I2[l]=G2[l]+ge;
					}
					if(i>0 && j>0)
					{
						D2[l]=min(D1[l],G1[l]+gi)+ge;
						I2[l]=min(I1[l-1],G1[l-1]+gi)+ge;
						if(s1[i]!=s2[j])
							s=1;
						else
							s=0;
						G2[l]=min1(D2[l],I2[l],G0[l-1]+s);
					}
				}
			}
			l++;
		}
		for(int t=0;t<=n;t++)
		{
			D0[t]=D1[t];
			D1[t]=D2[t];
			I0[t]=I1[t];
			I1[t]=I2[t];
			G0[t]=G1[t];
			G1[t]=G2[t];
		}
	}

	cost=min1(D1[n],I1[n],G1[n]);			//--- allignment cost
	
	cout<<"Optimal Allignment cost: "<<cost<<endl;
	
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

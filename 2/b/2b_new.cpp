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
	for(int i=1;i<=n;i++)
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
	
	int D0[n+1],D1[n+1],D2[n+1],G0[n+1],G1[n+1],G2[n+1],I0[n+1],I1[n+1],I2[n+1];				//--- declaration of functions
	int gi,ge,s,cost;
	gi=2;ge=1;

	G1[0]=0;										//--- initialization

	


	for(k=1;k<=2*n;k++)
	{
		if(k <=n)
		{	
			for(i =0; i<=k; i++)
			{
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
		}
		if(k > n)
		{
			for(i=0; i<=(n-(k-n)); i++)
			{
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
		}

		for(int t=0;t<=n;t++)
		{
			
			D1[t]=D2[t];
			I1[t]=I2[t];
			G0[t]=G1[t];
			G1[t]=G2[t];
		}
	}


	cost=min1(D2[0],I2[0],G2[0]);			//--- allignment cost
	
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

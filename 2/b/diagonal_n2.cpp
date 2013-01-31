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
	ifstream indata("rand-16-in.txt");		
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
	int D[n+1][n+1],G[n+1][n+1],I[n+1][n+1],u[n+1],v[n+1],se[n+1];				//--- declaration of functions
	int gi,ge,s,cost;
	gi=2;ge=1;

//	G[0][0]=0;										//--- initialization

	for(k=0;k<(2*n+1);k++)
	{
//		l=0;
		for(j=0;j<=n;j++)								//--- calculation of D,I,G
		{
			for(i=0;i<=n;i++)
			{
				if(i+j==k)
				{
					if(i==0 && j==0)
						G[i][j]=0;
					if(i==0 && j>0)
					{
						G[i][j]=gi+ge*j;
						D[i][j]=G[0][j]+ge;
					}
					if(i>0 && j==0)
					{
						G[i][j]=gi+ge*i;
						I[i][j]=G[i][0]+ge;
					}
					if(i>0 && j>0)
					{
						D[i][j]=min(D[i-1][j],G[i-1][j]+gi)+ge;
						if(s1[i]!=s2[j])
							s=1;
						else
							s=0;
						u[j] = min(D[i][j],G[i-1][j-1]+s);
						v[j] = u[j]+gi-j*ge;
						G[i][j]=min(u[j],I[i][j]);
						se[j]=v[j];
						for(int k=1; k<=j;k++)
						{
							if(se[j] > v[k])
								se[j]=v[k];
						}
						I[i][j+1]=se[j]+(j+1)*ge;
						if(j==1)
							I[i][1]=min(I[i][0],G[i][0]+gi) + ge;
		
						G[i][j]=min1(D[i][j],I[i][j],G[i-1][j-1]+s);
					}
				}
			}
		}
	}
	cost=min1(D[n][n],I[n][n],G[n][n]);			//--- allignment cost
	
	cout<<"Optimal Allignment cost: "<<cost<<endl;
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

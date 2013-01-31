#include<iostream>
#include<stdlib.h>
#include<math.h>
#include <sys/timeb.h>
#include <sys/types.h>
#include <time.h>

using namespace std;

int min(int,int);

int main(int argc, char ** argv)
{
        int i,m,t,k,s,h,n,j;
        time_t t0, t1;
        clock_t c0,c1;
//        struct timeb *begin, *end;

        cout<<"Enter the power of 2 (value of k)"<<endl;
        cin>>k;
        n=(int)pow(2,k);
        int *A = new int[n];
        int *S = new int[n];
        int *B = new int[2*n-1];
        int *C = new int[2*n-1];
        for(i=1;i<=n;i++)
            A[i]=rand()%10+1;
        for(i=1;i<=n;i++)
            cout<<A[i]<<"\t";
        cout<<"\n\n";

/*        t0=time(NULL);
        c0=clock();

        printf ("\tbegin (wall):            %ld\n", (long) t0);
        printf ("\tbegin (CPU):             %d\n", (int) c0);
*/
 //       ftime(begin);

        for(i=1;i<=n;i++)
            B[i]=A[i];

        m=n;
        t=0;

        for(h=1;h<=k;h++)
        {
            s=t;
            t=t+m;
            m=m/2;
            for(i=1;i<=m;i++)
                B[t+i]=min(B[s+(2*i)-1],B[s+(2*i)]);
        }

        for(h=k;h>=0;h--)
        {
            for(i=1;i<=m;i++)
            {
                if(i==1)
                    C[t+i]=B[t+i];
                else if(i%2==0)
                      C[t+i]=C[s+i/2];
                    else
                       C[t+i]=min(C[s+(i-1)/2],B[t+i]);
            }
            m=2*m;
            s=t;
            t=t-m;
        }
        for(i=1;i<=n;i++)
            S[i]=C[i];
        for(i=1;i<=n;i++)
            cout<<S[i]<<"\t";
        cout<<"\n";
        
//       ftime(end);
//        printf("Time elapsed :%d ",end.time - begin.time);
/*        t1=time(NULL);
        c1=clock();
        printf ("\telapsed wall clock time: %ld\n", (long) (t1 - t0));
        printf ("\telapsed CPU time:        %f\n", (float) (c1 - c0)/CLOCKS_PER_SEC);
  */
    return 0;
}

int min(int a,int b)
{
    if(a>b)
        return b;
    else
        return a;
}


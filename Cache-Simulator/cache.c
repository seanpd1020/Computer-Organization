#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<math.h>

typedef struct cache_type{
	int valid;
	int pre;
	unsigned long tag;
};

unsigned long precedence = 0;
unsigned long num_of_instr=0;
unsigned long missnum = 0;
unsigned long hitnum = 0;

long cache_size;
long block_size;
int associativity;  //0:direct-mapped , 1:4 way , 2:full way
int rep_alg;	//0:FIFO , 1:LRU
int index_len;  //log2(cache_size)+10-log2(block_size)-log2(num of ways)
int way_len;	//log2(num of ways)
int block_len;	//log2(block_size)

int access(unsigned long addr,struct cache_type cache[][1<<index_len])
{
//compute the address

	unsigned long tag;
	unsigned long index;
	unsigned long temp = 0;
	tag = addr>>(block_len+index_len);
	for(int i=0;i<index_len;i++){
		temp <<= 1;
		temp |= 0x01;
	}
	index = addr >> block_len & temp;

	
	int hit_or_miss = 0;//1:hit , 0:miss
	for(int i=0;i< 1<<way_len;i++){
		if(cache[i][index].valid == 1 && cache[i][index].tag == tag){
			if(rep_alg == 1)
				cache[i][index].pre = precedence;
			hit_or_miss = 1;
			hitnum++;
			hitpush(num_of_instr);
			break;
		}
	}	
	
	if(hit_or_miss == 0){
		missnum++;
		int j = 0;
		for(int i=0;i< 1<<way_len;i++)
			if(cache[i][index].pre < cache[j][index].pre)
				j = i;
		cache[j][index].valid = 1;
		cache[j][index].tag = tag;
		cache[j][index].pre = precedence;
		misspush(num_of_instr);
	}
	precedence++;
}

int hit[5000000];
int hittop = -1;
int hitisempty(){
	if(hittop==-1)
		return 1;
	else
		return 0;
}
int hitisfull(){
	if(hittop==5000000)
		return 1;
	else
		return 0;
}
void hitpush(int data){
	if(!hitisfull()){
		hittop++;
		hit[hittop]=data;
	}
	else
		printf("Stack is full!!!\n");
}

int miss[5000000];
int misstop = -1;
int missisempty(){
	if(misstop==-1)
		return 1;
	else
		return 0;
}
int missisfull(){
	if(misstop==5000000)
		return 1;
	else
		return 0;
}
void misspush(int data){
	if(!missisfull()){
		misstop++;
		miss[misstop]=data;
	}
	else
		printf("Stack is full!!!\n");
}


int main(int argc,char* argv[]){
	
	char file_input[30],file_output[30];
	if(strcmp(argv[1],"-input")==0){
		strcpy(file_input,argv[2]);
		strcpy(file_output,argv[4]);
		
	}
	else{
		strcpy(file_input,argv[4]);
		strcpy(file_output,argv[2]);
	}	

	char buff[13];
	int tar_addr;
	FILE *fp;
	fp = fopen(file_input,"r");
//get cache size, block size, associativity, replace_algorithm
	fgets(&buff[0],6,fp);
	cache_size = atoi(buff);
	fgets(&buff[0],6,fp);
	block_size = atoi(buff);
	fgets(&buff[0],6,fp);
	associativity = atoi(buff);
	fgets(&buff[0],6,fp);
	rep_alg = atoi(buff);


	if(associativity == 0)
	{//direct-mapped
		index_len = (int)log2((double)cache_size)+10-(int)log2((double)block_size);
		way_len = 0;
		block_len = (int)log2((double)block_size);
	}
	else if(associativity == 1)
	{//4-way set
		index_len = (int)log2((double)cache_size)+10-(int)log2((double)block_size)-2;
		way_len = 2;
		block_len = (int)log2((double)block_size);
	}
	else if(associativity == 2)
	{//full way set
		index_len = 0;
		way_len = (int)log2((double)cache_size)+10-(int)log2((double)block_size);
		block_len = (int)log2((double)block_size);
	}
	//printf("index_len = %d\nway_len = %d\nblock_len = %d\n",index_len,way_len,block_len);

//malloc memory to cache[][]
	struct cache_type **cache = (struct cache_type**)malloc((1<<way_len)*sizeof(struct cache_type*));
	for(int i=0;i<(1<<way_len);i++)
		cache[i] = (struct cache_type*)malloc((1<<index_len)*sizeof(struct cache_type));

//cache[][] initialize
	for(int i=0;i< (1<<index_len);i++){
		for(int j=0;j< (1<<way_len);j++){
			cache[j][i].valid = 0;
			cache[j][i].pre = -1;			
			cache[j][i].tag = 0;
		}
	}

	
//get address and access
	while(fgets(&buff[0],13,fp)){
		num_of_instr++;
		sscanf(buff,"0x%x",&tar_addr);		
		access(tar_addr,cache);
	}


//output to file
	fp = fopen(file_output,"w");
	fprintf(fp,"Hits instructions: ");
	int i = 0;
	while(i<=hittop)
	{
		if(i!=hittop) fprintf(fp,"%d,",hit[i]);
		else fprintf(fp,"%d",hit[i]);
		i++;
	}
	fprintf(fp,"\nMisses instructions: ");
	i = 0;
	while(i<=misstop)
	{
		if(i!=misstop) fprintf(fp,"%d,",miss[i]);
		else fprintf(fp,"%d",miss[i]);
		i++;
	}
	fprintf(fp,"\nMiss rate: %lf\n",(double)missnum/(hitnum+missnum));
	fclose(fp);

	return 0;
}

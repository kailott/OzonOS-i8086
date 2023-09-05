unsigned short int rgb_t( unsigned char r, unsigned char g, unsigned char b)
{
	return ((r & 0x1f)<<11)	+ ((g & 0x3f)<<5) + (b & 0x1f);
}


int main(void)
{
	unsigned short int *scr_buf;
	int i,k,j;
	unsigned char r,g,b;
	char msg1[] = "C Kernel load\n";
	//
	k_alloc_init();

	j = 0;
	r = 0;
	g = 0;
	b = 0;
	scr_buf =(void *) get_lfb_address();
	for (i= 0 ; i<768; i++)
	{
		for (k=0; k<1024; k++)
		{
			
			scr_buf[(i*1024) + k] = rgb_t(r,g,b);
		
		}
		g = 63 -  (i / 12);
		//r = i / 24;
		b = i / 24;
		
	}
		k_print(&msg1);
	while(1)
	{
		
	}
}
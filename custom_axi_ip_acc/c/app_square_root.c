/* Square root IP compute */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

typedef long long int u64;

int main(int argc, char **argv) {

  /* IP addresses definition */
  unsigned int axi_size = 0x10000;
  off_t axi_pbase = 0x80000000; /* physical base address */
  u64 *axi_vptr;
  int fd;

  if (argc>3)
    printf("Too much arguments. Only 1 arguments needed \n");

  value = atoi(argv[1]);

  if ((fd = open("/dev/mem", O_RDWR | O_SYNC)) == -1) {
    printf("Access memory error");
    return(0);
  }

  axi_vptr = (u64 *)mmap(NULL, axi_size, PROT_READ|PROT_WRITE, MAP_SHARED, fd, axi_pbase);

  axi_vptr[0] = value;
  axi_vptr[1] = 0X1;

  while(!(axi_vptr[2]&0x1));

  if (axi_vptr[2]&0x4 > 0) /* ERROR detected */
    return 0;
  else
    return axi_vptr[3]; /* Return value */

}

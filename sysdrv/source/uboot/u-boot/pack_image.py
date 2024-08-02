#!/usr/bin/python3

import os,sys,subprocess

# Partition	        Start Sector	            Number of Sectors	    Partition  Size	     PartNum in GPT	    Requirements
# MBR	            0	        00000000	    1	    00000001	    512	        0.5KB	 	 
# Primary GPT	    1	        00000001	    63	    0000003F	    32256	    31.5KB	 	 
# loader1	        64	        00000040	    7104	00001bc0	    4096000	    2.5MB	    1	            preloader (miniloader or U-Boot SPL)
# Vendor Storage	7168	    00001c00	    512	    00000200	    262144	    256KB	 	                SN,MAC and etc.
# Reserved Space	7680	    00001e00	    384	    00000180	    196608	    192KB	 	                Not used
# reserved1	        8064	    00001f80	    128	    00000080	    65536	    64KB	 	                legacy DRM key
# U-Boot ENV	    8128	    00001fc0	    64	    00000040	    32768	    32KB	 	 
# reserved2	        8192	    00002000	    8192	00002000	    4194304	    4MB	 	                    legacy parameter
# loader2	        16384	    00004000	    8192	00002000	    4194304	    4MB	        2	            U-Boot or UEFI
# trust	            24576	    00006000	    8192	00002000	    4194304	    4MB	        3	            trusted-os like ATF, OP-TEE
# boot	            32768	    00008000	    229376	00038000	    117440512	112MB	    4	            kernel, dtb, extlinux.conf, ramdisk
# rootfs	        262144	    00040000	    -	        -	            -	    -MB	        5	            Linux system
# Secondary GPT	    16777183	00FFFFDF	    33	    00000021	    16896	    16.5KB	 	 


#dd if=/dev/zero  of=header.img bs=1024 count=32768
#gdisk header.img       |create image
#r ->x ->l ->64 ->m  |change sector interval to 64

# Number  Start (sector)    End (sector)  Size       Code  Name
#    1              64            8064   3.9 MiB     8300  loader1
#    2            8128           16320   4.0 MiB     8300  env
#    3           16384           24512   4.0 MiB     8300  uboot
#    4           24576           32704   4.0 MiB     8300  trust
#    5           32768          131072   48.0 MiB    8300  kernel
#    6          131136          196574   32.0 MiB    8300  rootfs

PARTIONS_TABLE={
    "loader1":[64,      8064,   "/dev/none",    "./idbloader_op.img"],
    "uboot"  :[16384,   24512,  "/dev/none",    "./uboot.img"],
    # "trust"  :[24576,   32704,  "/dev/none",    "./trust.img"],
    # "kernel" :[32768,   131072, "/dev/none",    "./kernel.fat"],
}


class pack_imags :
    def __init__(self,sdcard_img:str,partions_table:dict,sector_size=512) -> None:
        self.sector_size =sector_size
        self.sdcard_img =sdcard_img
        self.partions_table=partions_table

    def __losetup_image(self,begin:int,stop:int):
        start_addr=begin*self.sector_size
        limit_size=(stop-begin)*self.sector_size
        os.system("losetup -f -o %d   --sizelimit %d  %s" % (start_addr,limit_size,self.sdcard_img))

    def losetup_on_images(self):
        for key in self.partions_table.keys():
            part =self.partions_table[key]
            if len(part[3]) > 0 and os.path.exists(part[3]):
                self.__losetup_image(part[0], part[1])


    def losetup_off_images(self):
        for key in self.partions_table.keys():
            part =self.partions_table[key]
            if os.path.exists(part[2]):
                os.system("losetup -d %s " % part[2])


    def copy_images(self):
        for key in self.partions_table.keys():
            part =self.partions_table[key]
            if len(part[3]) > 0 and os.path.exists(part[3]) and os.path.exists(part[2]):
                print("**************copy -----> image***************")
                print("copy %s %s" % (part[3],part[2]))
                os.system("dd if=%s of=%s bs=%d" % (part[3],part[2],self.sector_size))


    def __system_cmd(self,cmd:str):
        respond=[]
        pi =subprocess.Popen(cmd,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
        while pi.poll() is None:
            try:
                outline =str(pi.stdout.readline(),encoding="utf-8")
                respond.append(outline)
            except:
                print("unkown symbol that can not convert to string")
        return respond


    def __setup_loop_device(self,device:str,offset:int,sector_size=512):
        for key in self.partions_table.keys():
            part =self.partions_table[key]
            if offset == part[0] * sector_size:
                part[2] =device


    def show_loop_device(self):
        print("**************loop <----> image***************")
        for key in self.partions_table.keys():
            part =self.partions_table[key]
            print("{:<16s}{:<16s}{:<16s}".format(key, part[2],part[3]))

    def __remove_invaild(self,line:str):
        respond =[]
        lines =line.split(" ")
        for line in lines:
            if line:
                respond.append(line)
        return respond

    def update_loop_device(self):
        lines =self.__system_cmd("losetup -l")
        for line in lines:
            dataline =self.__remove_invaild(line)
            if len(dataline) == 8 and "/dev/loop" in dataline[0]:
                device =dataline[0]
                offset =int(dataline[2])
                self.__setup_loop_device(device,offset)


if __name__ == '__main__':  
    if len(sys.argv) > 1:
        pk =pack_imags(sdcard_img=sys.argv[1],partions_table=PARTIONS_TABLE)
        pk.losetup_on_images()
        pk.update_loop_device()
        pk.show_loop_device()
        pk.copy_images()
        pk.losetup_off_images()
    else:
        print("please specify the image file")



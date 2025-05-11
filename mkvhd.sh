qemu-img create -f vpc -o subformat=fixed oh.vhd 20G 
tail -c 512 oh.vhd > vhd_sig.bin
mv oh.vhd o.t
head -c -512 o.t > oh.vhd

(cat -  | { while read l ; do sleep 1; echo $l; done } | /sbin/gdisk oh.vhd) <<END

o
Y
n
1
2048
+500M
ef00
n
2
1026048
+5G
8300
n
3
11511808
+1G
8300
n
4
13608960
+10G
8300
c
1
ESP(0)
c
2
/(1)
c
3
/vendor(2)
c
4
data(3)
x
a
2

w
Y
END

#rm -f tmp.raw
#dd if=oh.vhd of=tmp.raw count=1 bs=512 skip=2048 seek=0 conv=notrunc

dd if=/dev/zero of=data.img bs=1G count=1
mkfs.ext4 -L 'data(4)' -F data.img

dd if=/dev/zero of=efi.img bs=1M count=300
mformat -F -v "ESP(0)" -i efi.img ::
mcopy -s -i efi.img  boot/* ::
mdir -/ -i efi.img ::

dd if=efi.img of=oh.vhd bs=512 skip=0 conv=notrunc seek=2048
dd if=system.img of=oh.vhd bs=512 skip=0 conv=notrunc seek=1026048
dd if=vendor.img of=oh.vhd bs=512 skip=0 conv=notrunc seek=11511808
dd if=data.img of=oh.vhd bs=512 skip=0 conv=notrunc seek=13608960
cat vhd_sig.bin >> oh.vhd


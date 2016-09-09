@rem upx.exe -9 --brute --lzma "R&Q.exe"
@del *.map
@rem copy RnQ.exe "R&Q.exe"
upx.exe -9 --lzma "ImportBase.exe"
@rem copy "R&Q.exe" "../../Release/R&Q.exe"
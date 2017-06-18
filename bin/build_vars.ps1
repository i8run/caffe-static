. "./build_funs.ps1"
# ��ȡCPU�߼���������
function get_logic_core_count(){
    $cpu=get-wmiobject win32_processor
    return @($cpu).count*$cpu.NumberOfLogicalProcessors
}
function get_os_processor(){
    try { 
        # �ȳ���ִ��linux�����жϲ���ϵͳ,�����쳣ʱִ��windows��ָ��
		$os=$(uname -s)
		$processor=$(uname -p)
    } catch { 
        $os="windows"
	    $arch=$env:PROCESSOR_ARCHITECTURE
        $processor="x86"
        if($arch -eq "AMD64"){
             $processor += "_64"
        }	    
    } 
    $os
    $processor
}
# ���ɰ�װ·������׺
function install_suffix([string]$prefix){
	args_not_null_empty_undefined prefix HOST_OS HOST_PROCESSOR
	return "${prefix}_${HOST_OS}_${HOST_PROCESSOR}"
}
# ���ݹ�ϣ���ṩ����Ϣ����project info����
function create_project_info([hashtable]$hash){
	args_not_null_empty_undefined hash INSTALL_PREFIX_ROOT
    $info= New-Object PSObject  -Property $hash
    # û�ж��� prefix �Ĳ�����install_path
    if($info.prefix){
	    Add-Member -InputObject $info -NotePropertyName install_path -NotePropertyValue $(Join-Path -ChildPath $(install_suffix $info.prefix) -Path $INSTALL_PREFIX_ROOT) 
    }
    $f=$info.prefix
    # ���û�ж���汾�ţ���folder��prefix��ͬ
    if($info.version){
       $f+="-"+$info.version
    }
	if(! $info.folder){
		Add-Member -InputObject $info -NotePropertyName folder -NotePropertyValue $f
	}
    return $info
}

# ָ��������
echo ������λ�ã�
echo MAKE_CXX_COMPILER:$MAKE_CXX_COMPILER
echo MAKE_C_COMPILER:$MAKE_C_COMPILER
# ����ϵͳ,CPU����
$HOST_OS,$HOST_PROCESSOR=get_os_processor
echo HOST_OS=$HOST_OS
echo HOST_PROCESSOR=$HOST_PROCESSOR

# cmake ��������
$CMAKE_VARS_DEFINE="-DCMAKE_CXX_COMPILER:FILEPATH=$MAKE_CXX_COMPILER -DCMAKE_C_COMPILER:FILEPATH=$MAKE_C_COMPILER -DCMAKE_BUILD_TYPE:STRING=RELEASE"
# �ű�����·��
$BIN_ROOT=$(Get-Item $MyInvocation.MyCommand.Definition).Directory
# ��Ŀ��Ŀ¼
$DEPENDS_ROOT=$BIN_ROOT.Parent.FullName
# ��װ��Ŀ¼
$INSTALL_PREFIX_ROOT=Join-Path -ChildPath release -Path $DEPENDS_ROOT
# Դ���Ŀ¼
$SOURCE_ROOT=Join-Path -ChildPath source -Path $DEPENDS_ROOT
# ѹ������Ŀ¼
$PACKAGE_ROOT=Join-Path -ChildPath package -Path $DEPENDS_ROOT 
# �����ļ���Ŀ¼
$PATCH_ROOT=Join-Path -ChildPath patch -Path $DEPENDS_ROOT 
# ������������Ŀ¼
$TOOLS_ROOT=Join-Path -ChildPath tools -Path $DEPENDS_ROOT 

# ���̱߳������ make -j 
$MAKE_JOBS=get_logic_core_count
##################################��Ŀ������Ϣ
$protobuf_hash=@{
	prefix="protobuf"
	version="3.3.1"
	md5="9377e414994fa6165ecb58a41cca3b40"
	owner="google"
	package_prefix="v"
}
$PROTOBUF_INFO= create_project_info $protobuf_hash
#$PROTOBUF_INFO

$glog_hash=@{
	prefix="glog"
	version="0.3.5"
	md5="454766d0124951091c95bad33dafeacd"
	owner="google"
	package_prefix="v"
}
$GLOG_INFO= create_project_info $glog_hash
#$GLOG_INFO

$gflags_hash=@{
	prefix="gflags"
	version="2.2.0"
	md5="f3d31a4225a7e0e6cac50b2b65525317"
	version_2_1_2="2.1.2"
	md5_2_1_2="5cb0a1b38740ed596edb7f86cd5b3bd8"
	owner="gflags"
	package_prefix="v"
}
$GFLAGS_INFO= create_project_info $gflags_hash
#$GFLAGS_INFO

$leveldb_hash=@{
	prefix="leveldb"
	version="1.18"
	md5="06e9f4984e40ccf27af366d5bec0580a"
	owner="google"
	package_prefix="v"
}
$LEVELDB_INFO= create_project_info $leveldb_hash
#$LEVELDB_INFO

$snappy_hash=@{
	prefix="snappy"
	version_1_1_4="1.1.4"
	md5_1_1_4="b9bdbb6818d9c66b31edb6c037fef3d0"
	version="master"
	owner="google"
	package_prefix=""
}
$SNAPPY_INFO= create_project_info $snappy_hash
#$SNAPPY_INFO

$openblas_hash=@{
	prefix="OpenBLAS"
	version="0.2.18"
	md5="4ca49eb1c45b3ca82a0034ed3cc2cef1"
	owner="xianyi"
	package_prefix="v"
}
$OPENBLAS_INFO= create_project_info $openblas_hash
#$OPENBLAS_INFO

$lmdb_hash=@{
	prefix="lmdb"
	version="0.9.21"
	md5="a47ddf0fade922e8335226726be5e6c4"
	owner="LMDB"
	package_prefix="LMDB_"
}
$LMDB_INFO= create_project_info $lmdb_hash
#$LMDB_INFO

# 1.0.5 zip ��(github����)
$bzip2_hash=@{
	prefix="bzip2"
	version="1.0.5"
	md5="052fec5cdcf9ae26026c3e85cea5f573"
	owner="LuaDist"
	package_prefix=""
}
$BZIP2_INFO= create_project_info $bzip2_hash

# 1.0.6 tar.gz��(���� bzip2.org ����)
$bzip2_1_0_6_hash=@{
	prefix="bzip2"
	version="1.0.6"
	md5="00b516f4704d4a7cb50a1d97e6e8e15b"
	package_prefix=""
    package_suffix=".tar.gz"
}
$BZIP2_1_0_6_INFO= create_project_info $bzip2_1_0_6_hash

$boost_hash=@{
	prefix="boost"
	version="1.58.0"
	md5="5a5d5614d9a07672e1ab2a250b5defc5"
    package_suffix=".tar.gz"
}
$BOOST_INFO= create_project_info $boost_hash
#$BOOST_INFO

$hdf5_hash=@{
	prefix="hdf5"
	version="1.8.16"
	md5="a7559a329dfe74e2dac7d5e2d224b1c2"
    package_suffix=".tar.gz"
}
$HDF5_INFO= create_project_info $hdf5_hash
#$HDF5_INFO

$opencv_hash=@{
	prefix="opencv"
	version_2_4_9="2.4.9"
	md5_2_4_9="7f958389e71c77abdf5efe1da988b80c"
	version="2.4.13.2"
	md5="e48803864e77fc8ae7114be4de732d80"
	owner="opencv"
	package_prefix=""
}
[PSObject]$OPENCV_INFO= create_project_info $opencv_hash
#$OPENCV_INFO

$ssd_hash=@{
	prefix="caffe"
    version="ssd"
    owner="weiliu89"	
}
$SSD_INFO= create_project_info $ssd_hash
#$SSD_INFO

$cmake_hash_linux=@{
    prefix="cmake"
    version="3.8.2"
	md5="ab02cf61915e1ad15b8523347ad37c46"
	folder="cmake-3.8.2-Linux-x86_64"
    package_suffix=".tar.gz"
}
$cmake_hash_windows=@{
    prefix="cmake"
    version="3.8.2"
    md5="8b28478c3c19d0e8ff895e8f4fd0c5b6"
    folder="cmake-3.8.2-win32-x86"
    package_suffix=".zip"
}
$CMAKE_INFO= create_project_info $cmake_hash_windows
# ����root����
Add-Member -InputObject $CMAKE_INFO -NotePropertyName root -NotePropertyValue (Join-Path -ChildPath $CMAKE_INFO.folder -Path $TOOLS_ROOT )
# ����exe����
Add-Member -InputObject $CMAKE_INFO -NotePropertyName exe -NotePropertyValue ([io.path]::combine($CMAKE_INFO.root,"bin","cmake"))
# ָ�������ѹ����
# ����ָ����exe����֧�����������еİ汾,
# ����7z�� GUI�汾�Ŀ�ִ���ļ��� 7zfm.exe,�����а汾����7z.exe
# ��ѹ(HaoZip)��GUI�汾�Ŀ�ִ���ļ��� HaoZip.exe,�����а汾���� HaoZipC.exe
# ��������ô�ֵ���ű���ͨ�� assoc,ftype������ң����п��ܲ��Ҳ���
#$UNPACK_TOOL="C:\Program Files\7-Zip\7z.exe"
#$UNPACK_TOOL="C:\Program Files\2345Soft\HaoZip\HaoZipC.exe"

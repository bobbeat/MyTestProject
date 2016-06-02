//
//  file.mm
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//

#include "file.h"
#include "stdio.h"
//#include "libgdc.h"
#include <sys/stat.h>
#include <sys/types.h>

/**
 **********************************************************************
 \brief 打开文件
 \details 根据传入的文件全路径和打开方式,开打文件。
 \param[in] szFileName	文件全路径
 \param[in] szMode		打开方式
 \retval	文件指针不为空-打开成功,为空-打开失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gfile* GPI_FileOpen(Gchar* szFileName, Gchar* szMode)
{
    NSLog(@"GPI_FileOpen");
	FILE* fp = GNULL;
	Gint8 fn[GMAX_PATH] = {0};
	Gint8 md[20] = {0};
    
	ConvertGcharToChar((Guint8 *)fn, szFileName);
    ConvertGcharToChar((Guint8 *)md, szMode);
    
	fp = fopen((const char*)fn, (const char*)md);
    
    return (Gfile*)fp;
}

/**
 **********************************************************************
 \brief 读取文件数据
 \details 根据传入的文件指针读取指定大小到相应的内存。
 \param[in] buffer	存储的空间
 \param[in] size		需要读取的字节大小
 \param[in] fp		文件指针
 \retval	返回实际读取的数据大小
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gint32 GPI_FileRead(void* buffer, Gint32 size, Gfile* fp)
{
	return (Gint32)fread(buffer, size,   1,(FILE *)fp);
}

/**
 **********************************************************************
 \brief 写入文件数据
 \details 根据传入的文件指针把指定大小的相应的内存内容存入文件里
 \param[in] buffer	存储的空间
 \param[in] size		需要读取的字节大小
 \param[in] fp		文件指针
 \retval	返回实际写入的数据大小
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gint32 GPI_FileWrite(void* buffer, Gint32 size, Gfile* fp)
{
	return (Gint32)fwrite(buffer, size, 1, (FILE *)fp);
}

/**
 **********************************************************************
 \brief 指定文件指针位置
 \details 根据传入的文件指针和相对位置格式偏移指定字节。
 \param[in] fp		文件指针
 \param[in] offset	偏移量
 \param[in] seek		相对位置格式
 \retval	0-成功 -1-失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gint32 GPI_FileSeek(Gfile* fp, Gint32 offset, GSEEK seek)
{
	return (Gint32)fseek((FILE *)fp,offset,seek);
}

/**
 **********************************************************************
 \brief 返回文件指针的位置
 \details 用于得到文件位置指针当前位置相对于文件首的偏移字节数。
 \param[in] fp		文件指针
 \retval	文件位置指针当前位置相对于文件首的偏移字节数
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gint32 GPI_FileTell(Gfile* fp)
{
	return (Gint32)ftell((FILE *)fp);
}

/**
 **********************************************************************
 \brief 获取文件大小
 \details 根据传入的文件指针获取相应的文件大小。
 \param[in] fp		文件指针
 \retval	文件大小
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gint32 GPI_FileLength(Gfile* fp)
{
	Gint32 ret = 0;
	Gint32 pos = 0;
    
	pos = (Gint32)ftell((FILE*)fp);
	(void)fseek((FILE*)fp, 0, SEEK_END);
	ret = (Gint32)ftell((FILE*)fp);
	(void)fseek((FILE*)fp, (long)pos, SEEK_SET);
    
	return ret;
}


/**
 **********************************************************************
 \brief 清除文件缓冲区
 \details 文件以写方式打开时将缓冲区内容写入文件。
 \param[in] fp		文件指针
 \retval	0-成功 非0-失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gint32 GPI_FileFlush(Gfile* fp)
{
	return (Gint32)fflush((FILE *)fp);
}

/**
 **********************************************************************
 \brief 从文件结构体指针中读取数据，每次读取一行
 \details 根据传入的文件指针中读取数据，每次读取一行。
 \param[in] buffer	存储的空间
 \param[in] size		需要读取的字节大小
 \param[in] fp		文件指针
 \retval	GNULL-失败获取文件结尾
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gchar* GPI_FileGets(Gchar* buffer, Gint32 size, Gfile* fp)
{
	Gchar* ret;
    char *fileBuffer = (char *)malloc(size * sizeof(char));
	ret = (Gchar*)fgets(fileBuffer, size, (FILE*)fp);
    ConvertChartoGchar(buffer, (Guint8)fileBuffer);
	return ret;
}

/**
 **********************************************************************
 \brief 打开文件
 \details 根据传入的文件全路径和打开方式,开打文件。
 \param[in] szFileName	文件全路径
 \param[in] szMode		打开方式
 \retval	文件指针不为空-打开成功,为空-打开失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gint8* GPI_FileGetsA(Gint8* buffer, Gint32 size, Gfile* fp)
{
	Gint8* ret;
	buffer[0] = (Gint8)0;
	ret = (Gint8*)fgets((char *)buffer, size, (FILE*)fp);
	return ret;
}

/**
 **********************************************************************
 \brief 检测流上的文件结束符
 \details 根据传入的文件指针检测流上的文件结束符。
 \param[in] fp		文件指针
 \retval	0-文件结束 非0-文件结束
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gbool GPI_FileEof(Gfile* fp)
{
	Gbool bRet = Gtrue;
	if (0 == feof((FILE*)fp))
	{
		bRet = Gfalse;
	}
	return bRet;
}

/**
 **********************************************************************
 \brief 关闭文件流
 \details 可以把缓冲区内最后剩余的数据输出到磁盘文件中，并释放文件指针和有关的缓冲区。
 \param[in] fp		文件指针
 \retval	0-成功 非0-失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gint32 GPI_FileClose(Gfile* fp)
{
	return (Gint32)fclose((FILE *)fp);
}

/**
 **********************************************************************
 \brief 创建目录
 \details 根据传入的目录名称，新建目录。
 \param[in] szDir	目录名
 \retval	Gtrue   创建成功
 \retval	Gfalse	创建失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gbool GPI_CreateDirectory(const Gchar *szDir)
{
	Gbool ret = Gfalse;
	Gint8 path[GMAX_PATH] = {0};
    ConvertGcharToChar((Guint8 *)path, (Gchar *)szDir);
	if(mkdir((const char*)path, S_IRWXU|S_IRWXG|S_IRWXO)==0)
		ret = Gtrue;
	else
		ret = Gfalse;
    
	return ret;
}

/**
 **********************************************************************
 \brief 遍历文件
 \details 查找指定文件并返回找到的符合条件的文件个数。
 \param[in] szDir		目录
 \param[in] szPattern	匹配模式
 \param[in] lpFindFileCB	回调接口
 \retval	num   找到的文件总数
 \remarks
 - lpFindFileCB返回Gfalse表示不再继续查找。
 \since 6.0
 \see GDBL_GetTrackList
 **********************************************************************/
Gint32 GPI_FindFile(Gchar *szDir, Gchar *szPattern, FINDFILECB lpFindFileCB)
{
    NSString *dirPath = GcharToNSString(szDir);
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *array = [manager contentsOfDirectoryAtPath:dirPath error:nil];
    FILEINFO fi = {0};
    NSString *match = GcharToNSString(szPattern);
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", match];
    NSArray *results = [array filteredArrayUsingPredicate:predicate];
    for (int i = 0; i < [results count]; i++)
    {
        NSString *filePath = [dirPath stringByAppendingFormat:@"/%@",[array objectAtIndex:i]];
        NSDictionary *dic = [manager  attributesOfItemAtPath:filePath error:nil];
        long size = [[dic objectForKey:@"NSFileSize"] longValue];
        fi.nFileSizeLow = size;
        GcharMemcpy(fi.szFileName, NSStringToGchar([array objectAtIndex:i]), GMAX_PATH);
        lpFindFileCB(&fi);
    }
	return [results count];
}

/**
 **********************************************************************
 \brief 文件重命名
 \details 传入新、旧文件名，调用平台相关接口，实现文件重命名。
 \param[in] szOldFileName	新文件名
 \param[in] szNewFileName	旧文件名
 \param[in] lpFindFileCB	回调接口
 \retval	0   操作成功
 \retval	2   文件未找到
 \retval	3   路径错误
 \remarks
 \since 6.0
 \see GDBL_GetTrackList
 **********************************************************************/
Guint32 GPI_RenameFile(const Gchar *szOldFileName, const Gchar *szNewFileName)
{
	Gint8 oldpath[GMAX_PATH] = {0};
	Gint8 newpath[GMAX_PATH] = {0};
    ConvertGcharToChar((Guint8 *)oldpath, (Gchar *)szOldFileName);
    ConvertGcharToChar((Guint8 *)newpath, (Gchar *)szNewFileName);
	return (Guint32)rename((const char*)oldpath,(const char*)newpath);
}

/**
 **********************************************************************
 \brief 删除文件
 \details 传入需要删除的文件名，调用平台相关接口，实现文件删除。
 \param[in] szFileName	新文件名
 \param[in] lpFindFileCB	回调接口
 \retval	0   删除成功
 \retval	2   文件未找到
 \retval	3   路径错误
 \remarks
 \since 6.0
 \see GDBL_GetTrackList
 **********************************************************************/
Guint32 GPI_DeleteFile(const Gchar *szFileName)
{
	int ret = 0;
	Gint8 path[GMAX_PATH] = {0};
    ConvertGcharToChar((Guint8 *)path, (Gchar *)szFileName);
	if(remove((const char*)path)==0)
		ret = 0;
	else
		ret = 2;
	//	}
	return ret;
    
}

/**
 **********************************************************************
 \brief 删除目录
 \details 传入需要删除的目录名，调用平台相关接口，实现目录删除。
 \param[in] szDirectory	目录所在的路径
 \retval	Gtrue   删除成功
 \retval	Gfalse   删除失败
 \remarks 删除失败可能有多种原因
 \since 6.0
 \see GDBL_GetTrackList
 **********************************************************************/
Gbool GPI_DeleteDirectory(const Gchar *szDirectory)
{
    Gint8 path[GMAX_PATH] = {0};
    ConvertGcharToChar((Guint8 *)path, (Gchar *)szDirectory);
    NSString *imageDir = [NSString stringWithUTF8String:(const char *)path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager removeItemAtPath:imageDir error:nil])
    {
        return Gtrue;
    }
    return Gfalse;
}

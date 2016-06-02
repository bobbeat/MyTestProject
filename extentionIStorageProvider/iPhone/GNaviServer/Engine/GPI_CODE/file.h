/* ***************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: file.h
 * Purpose:文件操作对外接口
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 12-Jul-2013 18:00:06
 * Update: Create
 *
 *************************************************** */
#ifndef FILE_H__
#define FILE_H__

#ifdef __cplusplus
extern "C"
{
#endif
    
#include "gtypes.h"
#include "gpimacro.h"
    
    
    /**
     \defgroup gpi_data_structures_group GPI Data Structures
     \{
     */
    
    /**
     * 文件信息结构类型
     * 定义文件的属性，如文件大小
     * 文件名称等
     */
    typedef struct tagFILEINFO
    {
        Guint32 nFileSizeHigh; /**< 文件大小高32位 */
        Guint32 nFileSizeLow; /**< 文件大小低32位 */
        Gchar  szFileName[GMAX_PATH]; /**< 文件名 */
    } FILEINFO;
    
    /* 定义搜索文件的回调函数，返回Gfalse表示不再继续查找 */
    typedef Gbool (*FINDFILECB)(FILEINFO*);
    
    /** \} */
    
    /** \addtogroup platform_api_file_group
     \{ */
    
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
    GPI_API_CALL Gfile* GPI_FileOpen(Gchar* szFileName, Gchar* szMode);
    
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
    GPI_API_CALL Gint32 GPI_FileRead(void* buffer, Gint32 size, Gfile* fp);
    
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
    GPI_API_CALL Gint32 GPI_FileWrite(void* buffer, Gint32 size, Gfile* fp);
    
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
    GPI_API_CALL Gint32 GPI_FileSeek(Gfile* fp, Gint32 offset, GSEEK seek);
    
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
    GPI_API_CALL Gint32 GPI_FileTell(Gfile* fp);
    
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
    GPI_API_CALL Gint32 GPI_FileLength(Gfile* fp);
    
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
    GPI_API_CALL Gint32 GPI_FileFlush(Gfile* fp);
    
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
    GPI_API_CALL Gchar* GPI_FileGets(Gchar* buffer, Gint32 size, Gfile* fp);
    
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
    GPI_API_CALL Gint8* GPI_FileGetsA(Gint8* buffer, Gint32 size, Gfile* fp);
    
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
    GPI_API_CALL Gbool GPI_FileEof(Gfile* fp);
    
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
    GPI_API_CALL Gint32 GPI_FileClose(Gfile* fp);
    
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
    GPI_API_CALL Gbool GPI_CreateDirectory(const Gchar *szDir);
    
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
    GPI_API_CALL Gint32 GPI_FindFile(Gchar *szDir, Gchar *szPattern, FINDFILECB lpFindFileCB);
    
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
    GPI_API_CALL Guint32 GPI_RenameFile(const Gchar *szOldFileName, const Gchar *szNewFileName);
    
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
    GPI_API_CALL Guint32 GPI_DeleteFile(const Gchar *szFileName);
    
    /**
     **********************************************************************
     \brief 删除目录
     \details 传入需要删除的目录名，调用平台相关接口，实现目录删除。
     \param[in] szDirectory	目录所在的路径
     \retval	Gtrue   删除成功
     \retval	Gfalse   删除失败
     \remarks 删除失败可能有多种原因
     \since 6.0
     \see 
     **********************************************************************/
    GPI_API_CALL Gbool GPI_DeleteDirectory(const Gchar *szDirectory);
    
    /* below this line DO NOT add anything */
    /** \} */
    
#ifdef __cplusplus
}
#endif
#endif


//
//  systime.mm
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//

#include "systime.h"

/**
 **********************************************************************
 \brief sleep指定毫秒数
 \details 传入参数，做延时用。
 \param[in] uMilliseconds 毫秒数
 \remarks
 - 调用windows平台接口，实现延时。
 \since 6.0
 \see
 **********************************************************************/
void GPI_Sleep(Guint32 uMilliseconds)
{
    if (uMilliseconds <= 0)
    {
        return;
    }
    usleep(uMilliseconds * 1000);
}

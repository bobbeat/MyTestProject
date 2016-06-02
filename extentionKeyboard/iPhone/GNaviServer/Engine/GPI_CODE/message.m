//
//  message.mm
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//

#include "message.h"



static void *m_msgCB = GNULL;
/**
 *********************************************************************
 \brief 消息发送
 \details 该函数调用平台相关接口实现消息发送。
 \param[in] uMsg	消息ID
 \param[in] wp	 消息参数高位
 \param[in] lp	 消息参数低位
 \remarks
 \since 7.0
 \see
 **********************************************************************/

void GPI_SetMessageCB(void *pCB)
{
	m_msgCB = pCB;
}

void GPI_PostMessage(Gint32 uMsg, void* wp, void* lp)
{
	if(m_msgCB == GNULL)
		return ;
    
	((void (*)(Gint32 , void* , void*))m_msgCB)(uMsg, wp, lp);
}

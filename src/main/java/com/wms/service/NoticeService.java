package com.wms.service;

import com.wms.entity.Notice;
import java.util.List;

public interface NoticeService {

    /**
     * 分页获取通告列表
     */
    List<Notice> getNoticePage(Integer pageNum, Integer pageSize);

    /**
     * 获取通告总数
     */
    int getTotalCount();

    /**
     * 添加新通告
     */
    boolean addNotice(Notice notice);

    /**
     * 更新通告
     */
    boolean updateNotice(Notice notice);

    /**
     * 删除通告
     */
    boolean deleteNotice(Integer id);

    /**
     * 根据ID获取通告详情
     */
    Notice getNoticeById(Integer id);

    /**
     * 置顶/取消置顶通告
     */
    boolean toggleTopNotice(Integer id);
}
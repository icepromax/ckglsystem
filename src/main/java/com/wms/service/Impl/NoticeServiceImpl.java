package com.wms.service.Impl;

import com.wms.entity.Notice;
import com.wms.mapper.NoticeMapper;
import com.wms.service.NoticeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class NoticeServiceImpl implements NoticeService {

    @Autowired
    private NoticeMapper noticeMapper;

    @Override
    public List<Notice> getNoticePage(Integer pageNum, Integer pageSize) {
        int offset = (pageNum - 1) * pageSize;
        return noticeMapper.selectPageList(offset, pageSize);
    }

    @Override
    public int getTotalCount() {
        return noticeMapper.selectTotalCount();
    }

    @Override
    public boolean addNotice(Notice notice) {
        notice.setPublishTime(LocalDateTime.now());
        return noticeMapper.insert(notice) > 0;
    }

    @Override
    public boolean updateNotice(Notice notice) {

        return noticeMapper.updateById(notice) > 0;
    }

    @Override
    public boolean deleteNotice(Integer id) {
        return noticeMapper.deleteById(id) > 0;
    }

    @Override
    public Notice getNoticeById(Integer id) {
        return noticeMapper.selectById(id);
    }

    @Override
    @Transactional
    public boolean toggleTopNotice(Integer id) {
        // 1. 先查询现有数据
        Notice existingNotice = noticeMapper.selectById(id);
        if (existingNotice == null) {
            throw new RuntimeException("通告不存在");
        }

        // 2. 只更新isTop字段（取反）
        Notice updateNotice = new Notice();
        updateNotice.setId(id);
        updateNotice.setIsTop(!existingNotice.getIsTop());
        updateNotice.setPublishTime(existingNotice.getPublishTime());
        updateNotice.setTitle(existingNotice.getTitle());
        updateNotice.setContent(existingNotice.getContent());
        // 3. 执行更新
        return noticeMapper.updateById(updateNotice) > 0;
    }
}
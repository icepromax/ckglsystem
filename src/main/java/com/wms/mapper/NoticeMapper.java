package com.wms.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.entity.Notice;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;




@Mapper
public interface NoticeMapper {
    List<Notice> selectPageList(Integer offset, Integer size);
    int selectTotalCount();
    int insert(Notice notice);
    int updateById(Notice notice);
    int deleteById(Integer id);
    Notice selectById(Integer id);
}
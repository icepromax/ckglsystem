package com.wms.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("notice")
public class Notice {
    @TableId(type = IdType.AUTO)
    private Integer id;
    private String title;
    private String content;
    private String publisher;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime publishTime;
    private Boolean isTop;
}
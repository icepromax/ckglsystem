package com.wms.controller;

import com.wms.common.Result;
import com.wms.entity.Notice;
import com.wms.service.NoticeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;


import java.util.List;

@Validated
@RestController
@RequestMapping("/notice")
public class NoticeController {

    private final NoticeService noticeService;

    @Autowired
    public NoticeController(NoticeService noticeService) {
        this.noticeService = noticeService;
    }

    /**
     * 分页获取通告列表
     * @param pageNum 页码 (从1开始)
     * @param pageSize 每页数量
     */
    @GetMapping("/page")
    public Result getNoticePage(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {

        System.out.println("接收到请求，pageNum=" + pageNum + ", pageSize=" + pageSize);

        List<Notice> notices = noticeService.getNoticePage(pageNum, pageSize);
        long total = noticeService.getTotalCount();

        return Result.success(notices,total);
    }

    /**
     * 添加新通告
     * @param notice 通告信息
     */
    @PostMapping("/add")
    public Result addNotice(@RequestBody  Notice notice) {
        boolean success = noticeService.addNotice(notice);
        return success ?
                Result.success("通告发布成功") :
                Result.fail();
    }

    /**
     * 更新通告
     * @param notice 通告信息
     */
    @PostMapping("/update")
    public Result updateNotice(@RequestBody  Notice notice) {
        boolean success = noticeService.updateNotice(notice);
        return success ?
                Result.success("通告更新成功") :
                Result.fail();
    }

    /**
     * 删除通告
     * @param id 通告ID
     */
    @DeleteMapping("/delete/{id}")
    public Result deleteNotice(@PathVariable  Integer id) {
        boolean success = noticeService.deleteNotice(id);
        return success ?
                Result.success("通告删除成功") :
                Result.fail();
    }

    /**
     * 获取通告详情
     * @param id 通告ID
     */
    @GetMapping("/{id}")
    public Result getNoticeDetail(@PathVariable  Integer id) {
        Notice notice = noticeService.getNoticeById(id);
        return notice != null ?
                Result.success(notice) :
                Result.fail();
    }

    /**
     * 置顶/取消置顶通告
     * @param id 通告ID
     */
    @PatchMapping("/{id}/top")
    public Result toggleTopNotice(@PathVariable  Integer id) {

        boolean success = noticeService.toggleTopNotice(id);
        return success ?
                Result.success(  "操作已完成" ) :
                Result.fail();
    }
}
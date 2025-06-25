package com.wms.controller;


import com.wms.common.Result;
import com.wms.entity.Menu;
import com.wms.service.MenuService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 *  前端控制器：菜单栏模块
 *
 */
@RestController
@RequestMapping("/menu")
public class MenuController {
    @Autowired
    private MenuService menuService;

    /*
     * 根据用户身份获取菜单列表
     */
    @GetMapping("/list")
    public Result list(@RequestParam String roleId){
        List list = menuService.lambdaQuery()
                .like(Menu::getMenuright,roleId)
                .list();
        return Result.success(list);
    }
}

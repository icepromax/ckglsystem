package com.wms.service;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.entity.Storage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.entity.dto.CategoryDataDTO;

import java.util.List;

/**
 * <p>
 *  服务类
 * </p>
 *
 */
public interface StorageService extends IService<Storage> {
    IPage pageCC(IPage<Storage> page, Wrapper wrapper);

    List<CategoryDataDTO> getQuantityStats();
}

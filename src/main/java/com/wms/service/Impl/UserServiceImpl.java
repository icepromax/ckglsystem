package com.wms.service.Impl;

import com.baomidou.mybatisplus.core.conditions.Wrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.entity.User;
import com.wms.mapper.UserMapper;
import com.wms.service.UserService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * <p>
 *  服务实现类
 * </p>
 *
 */
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {
    @Autowired
    private UserMapper userMapper;
    @Override
    public IPage pageC(IPage<User> page) {
        return userMapper.pageC(page);
    }

    @Override
    public IPage pageCC(IPage<User> page, Wrapper wrapper) {
        return userMapper.pageCC(page,wrapper);
    }

    @Override
    public Map<String, Long> getUserGenderStats() {
        // 查询总人数
        long total = this.count();

        // 查询男生数量
        long male = this.lambdaQuery()
                .eq(User::getSex, "1") // 假设"1"表示男性
                .count();

        // 查询女生数量
        long female = this.lambdaQuery()
                .eq(User::getSex, "0") // 假设"0"表示女性
                .count();

        Map<String, Long> stats = new HashMap<>();
        stats.put("total", total);
        stats.put("male", male);
        stats.put("female", female);

        return stats;
    }
}

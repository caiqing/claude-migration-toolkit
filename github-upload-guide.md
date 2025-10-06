# GitHub项目上传操作指南

## 第一步：准备GitHub仓库

1. 登录 [GitHub.com](https://github.com)
2. 点击右上角 "+" → "New repository"
3. 填写仓库信息：
   - Repository name: `claude-migration-toolkit`
   - Description: `基于Specify框架的项目模板，用于规范化的功能开发流程`
   - 选择 Public 或 Private
   - **不要勾选** "Initialize this repository with README"
4. 点击 "Create repository"

## 第二步：连接本地仓库

```bash
# 替换下面的YOUR_USERNAME为你的GitHub用户名
git remote add origin https://github.com/YOUR_USERNAME/claude-migration-toolkit.git

# 验证连接
git remote -v
```

## 第三步：推送到GitHub

```bash
# 添加所有文件到暂存区
git add .

# 提交更改
git commit -m "feat: 初始化项目并添加GitHub上传指南"

# 首次推送到GitHub（建立上游分支）
git push -u origin master
```

## 如果遇到认证问题

### 方法1：使用Personal Access Token（推荐）
1. GitHub设置 → Developer settings → Personal access tokens
2. 生成新令牌，选择 `repo` 权限
3. 推送时用令牌代替密码

### 方法2：配置SSH密钥
```bash
# 生成SSH密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 将公钥添加到GitHub账户
cat ~/.ssh/id_ed25519.pub

# 使用SSH地址
git remote set-url origin git@github.com:YOUR_USERNAME/claude-migration-toolkit.git
```

## 验证上传成功

1. 访问你的GitHub仓库页面
2. 检查文件是否都已上传
3. 查看README.md显示是否正常

## 后续维护

```bash
# 日常开发流程
git add .
git commit -m "feat: 添加新功能"
git push
```
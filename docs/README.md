# GitHub Pages 发布说明

本目录是项目的可索引静态站。发布时，在 GitHub 仓库的 **Settings → Pages** 中选择：

- Source：**Deploy from a branch**
- Branch：`main`
- Folder：`/docs`

首次发布后，默认地址为：

`https://jumorhack.github.io/claude-recharge-tutorial/`

## 自定义域名

本版先以默认 GitHub Pages 地址作为 canonical URL 与 sitemap 地址。配置并验证自定义域名后，再统一更新：

1. `robots.txt` 和 `sitemap.xml` 中的站点地址；
2. 所有 HTML 中的 `canonical`、Open Graph URL/image 与 JSON-LD URL；
3. GitHub Pages 的 Custom domain 设置。

不要在域名切换前添加 `CNAME`。保留同一套正文，避免让 README 与站点重复发布完整文章。

## 发布前验证

在仓库根目录运行：

```bash
./scripts/validate-site.sh
```

脚本会检查 HTML 页面数、必需元数据、JSON-LD、站内相对链接与 sitemap XML。

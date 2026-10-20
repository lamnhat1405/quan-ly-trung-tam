# EduManager – Quản lý trung tâm dạy thêm

Kiến trúc: **GitHub Pages** (giao diện tĩnh `index.html`) + **Supabase** (PostgreSQL, đăng nhập, phân quyền RLS, dữ liệu đồng bộ thời gian thực giữa mọi người dùng).

## Cài đặt
1. Tạo dự án miễn phí tại supabase.com.
2. **SQL Editor** → dán toàn bộ `schema.sql` → Run.
3. **Authentication → Providers → Email**: tắt *Confirm email* và tắt *Allow new users to sign up* (nhân sự chỉ do Quản trị tạo).
4. **Authentication → Users → Add user**: tạo tài khoản đầu tiên (tự động thành **Quản trị**).
5. **Project Settings → API**: chép *Project URL* và *anon key*, dán vào đầu đoạn `<script>` trong `index.html` (`SB_URL`, `SB_KEY`).

## Chạy thử
`python3 -m http.server 8000` rồi mở http://localhost:8000

## Triển khai bằng GitHub
1. Tạo repo, đẩy `index.html`, `schema.sql`, `README.md` lên nhánh `main`.
2. Repo → **Settings → Pages** → Source: *Deploy from a branch* → `main` / `(root)`.
3. Sau ~1 phút truy cập `https://<user>.github.io/<repo>/`.

## Cấu trúc & mở rộng
- `schema.sql`: bảng + quyền theo vai trò (danh sách ở cuối file).
- `index.html`: cấu hình thực thể `E` (cột, trường nhập, quyền sửa) → thêm module mới chỉ cần thêm một mục vào `E` và `NAV`.
- Vai trò: Quản trị, Quản lý, Tư vấn tuyển sinh, Giáo vụ, Kế toán, Giáo viên.

## Tự động deploy (đã kèm sẵn)
Thư mục có `.github/workflows/pages.yml`. Nếu dùng cách này: **Settings → Pages → Source: GitHub Actions**, mỗi lần push lên `main` web sẽ tự cập nhật.
Lưu ý: `anon key` của Supabase là khóa công khai, được phép nằm trong code; dữ liệu được bảo vệ bằng RLS trong `schema.sql`. Tuyệt đối không dùng `service_role key`.

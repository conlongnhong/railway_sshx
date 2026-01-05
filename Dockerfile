# ===============================
#   WINDOWS + SSHX + KEEP ALIVE
#   Railway Ready (Windows Version)
# ===============================
# Sử dụng Python trên Windows Server Core LTSC 2022
FROM python:3.11-windowsservercore-ltsc2022

# Thiết lập PowerShell làm shell mặc định để chạy lệnh dễ hơn
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Timezone Việt Nam (Tương đương SE Asia Standard Time trên Windows)
RUN tzutil /s 'SE Asia Standard Time'

# Railway web service port
ENV PORT=8080

# -------------------------------
# Cài đặt các gói cần thiết
# -------------------------------
# 1. Cài đặt VC++ Redistributable (BẮT BUỘC để chạy sshx trên Windows Container)
# Nếu thiếu gói này, sshx sẽ bị crash mà không báo lỗi.
ADD https://aka.ms/vs/17/release/vc_redist.x64.exe C:/vc_redist.exe
RUN Start-Process -FilePath C:\vc_redist.exe -ArgumentList '/install', '/quiet', '/norestart' -Wait; \
    Remove-Item C:\vc_redist.exe

# 2. Tải SSHX (Phiên bản Windows x64 MSVC)
ADD https://sshx.s3.amazonaws.com/sshx-x86_64-pc-windows-msvc.zip C:/sshx.zip
RUN tar -xf C:\sshx.zip -C C:\; \
    Remove-Item C:\sshx.zip

# -------------------------------
# Command chạy:
# 1. Start web service ảo (python http.server)
# 2. Chạy sshx
# -------------------------------
CMD Start-Process python -ArgumentList '-m', 'http.server', $Env:PORT -NoNewWindow; \
    Write-Host '🚀 Starting SSHX...'; \
    C:\sshx.exe

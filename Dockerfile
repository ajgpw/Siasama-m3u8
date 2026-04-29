# 1. Pythonの公式イメージ（スリム版）をベースに使用
FROM python:3.10-slim

# 2. 環境変数の設定
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=5000

# 3. 必要なシステムパッケージのインストール
# curl: Node.jsインストール用
# ffmpeg: yt-dlpの動画処理用
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# 4. Node.js v20 (LTS) のインストール
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && node -v # インストール確認

# 5. 作業ディレクトリの作成
WORKDIR /app

# 6. 依存関係ファイルのコピーとインストール
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -U yt-dlp

# 7. アプリケーションソースのコピー
COPY . .

# 8. Gunicornで起動
# タイムアウトを30秒に設定し、Renderの制限に合わせる
CMD gunicorn --bind 0.0.0.0:$PORT --timeout 30 --workers 1 app:app

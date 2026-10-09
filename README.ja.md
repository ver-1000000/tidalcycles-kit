<p align="center">
  <a href="./README.md">English</a> · 日本語
</p>

# tidalcycles-kit

TidalCyclesの演奏環境を、コンテナにまとめたキットです。
HaskellやSuperColliderをPCに直接インストールせずに、VS CodeやNeovimから演奏できます。

WindowsやmacOSへの対応も、今後検討していきたいと考えています。

## はじめる

PipeWire・Bash 4以上・Gitが動作し、同じホストで `docker compose` または `podman compose` を使えるLinux環境が必要です。

以下はDockerでの手順です。 Podmanを使う場合は、`docker compose` を `podman compose` に置き換えてください。

```sh
git clone https://github.com/ver-1000000/tidalcycles-kit.git
cd tidalcycles-kit
docker compose up
```

初回はプログラムと音源の取得・ビルドに数分かかる場合があります。

**`TIDAL_KIT_AUDIO_READY` が表示されたら、演奏環境の準備完了です。**
ターミナルを開いたまま、次のエディタ設定へ進んでください。

### 起動・停止のコマンド

リポジトリのディレクトリで実行します。

| やりたいこと | コマンド |
| --- | --- |
| バックグラウンドで起動する | `docker compose up -d` |
| バックグラウンドで起動し、準備完了まで待つ | `docker compose up --wait` |
| 起動せず、イメージだけビルドする | `docker compose build` |
| 更新後にビルドし直して起動する | `docker compose up --build` |
| 演奏環境を停止する | `docker compose down` |

更新後は、エディタ側のTidalセッションも接続し直してください。

## エディタで使う

演奏環境を起動したまま、使うエディタの設定を行ってください。
パスはこのリポジトリの**絶対パス**に置き換え、エディタは曲のフォルダを作業ディレクトリにして開いてください。

### VS Code

1. [TidalCycles拡張機能](https://marketplace.visualstudio.com/items?itemName=tidalcycles.vscode-tidalcycles)をインストール
2. [設定例](editors/vscode.settings.json)の2つのパスを書き換え、プロジェクトのVS Code設定へ追加
3. `.tidal` ファイルを開き、拡張機能の実行・停止コマンドで演奏

拡張機能がシェル経由で起動するため、リポジトリは**空白を含まないパス**に置いてください。

演奏環境はVS Code内のターミナルからも起動できます。 `docker compose up` のログを表示したまま演奏し、終了時はターミナルで `Ctrl+C` を押します。

### Neovim: vim-tidal

[vim-tidal](https://github.com/tidalcycles/vim-tidal)をインストールし、**プラグインを読み込む前に**次の設定を読み込んでください。

```vim
source /path/to/tidalcycles-kit/editors/vim-tidal.vim
```

`.tidal` ファイルを開くと、プラグインの実行・停止コマンドを使えます。 演奏を止めるには `:TidalHush` を実行します。

### Neovim: tidal.nvim

[tidal.nvim](https://github.com/grddavies/tidal.nvim)をインストールし、次の設定を読み込んでください。

```lua
dofile('/path/to/tidalcycles-kit/editors/tidal.nvim.lua')
```

`.tidal` ファイルを開き、`:TidalLaunch` で接続すると、プラグインの実行・停止コマンドを使えます。

## トラブルシューティング

まず、リポジトリのディレクトリで状態と音声側のログを確認してください。

```sh
docker compose ps -a
docker compose logs --tail=100 audio
```

- **DockerとPodmanが両方入っている**
  - エディタ接続はPodmanを優先するため、Dockerを使う場合は `export TIDAL_KIT_ENGINE=docker` を設定したシェルからエディタを起動してください
- **PipeWireソケットが見つからない**
  - PipeWireを動かしているユーザーのターミナルで実行し、`XDG_RUNTIME_DIR` と、その中の `pipewire-0` ソケットを確認してください
  - SSHや `sudo` 経由では環境が異なる場合があります
- **`UDP 57110 is occupied` / `UDP 57120 is occupied` が出る**
  - `ss -lunp` で、同じポートを使うSuperCollider・SuperDirtなどを確認し、競合している演奏環境を停止してください
- **エディタから接続できない**
  - 設定の絶対パスと、Compose・エディタで使うエンジンを確認してください
  - 作業ディレクトリがホーム全体や `/` の場合、共有は拒否されます
- **起動済みなのに音が出ない**
  - エディタの実行エラー、PipeWireの出力先、ミュートと音量を確認してください
  - 音量は少しずつ上げてください
- **演奏環境を停止してもエディタのTidalが残る**
  - エディタの接続は別コンテナです。 プラグインでセッションを終了するか、GHCiに `:quit` を送ってください
  - `hush` は演奏だけを止めます

## ライセンス

kit自身のコードは[MITライセンス](LICENSE)です。 依存ソフトウェアにはそれぞれのライセンスが適用されます。

詳細は[第三者ソフトウェアについて](THIRD_PARTY.md)を参照してください。

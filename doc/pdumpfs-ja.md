# pdumpfs: Plan9もどきのバックアップシステム

最終更新日: 2004-12-20 (公開日: 2001-02-18)

[English](pdumpfs.md) | Japanese

---

## pdumpfs とは?

pdumpfs は [Plan9](http://plan9.aichi-u.ac.jp/) の [dumpfs](http://plan9.aichi-u.ac.jp/dumpfs/) もどきの単純なバックアップシステムです。[Ruby](http://www.ruby-lang.org/) で実装されています。 毎日のスナップショットを保存するため、いつでも過去のファイル を取り戻すことができます。ホームディレクトリのバックアップに 利用すると便利です。

pdumpfs はバックアップ先ディレクトリに「年/月/日」の形式でスナップショットを保存します。初回のみバックアップ対象ディレクトリ全体をコピーして、2日目以降は差分でバックアップしていきます。ディスクの消費量を節約するために、更新されなかったファイルは前日のスナップショットのファイルへのハードリンクとして記録されます。

## 新着情報

*   *2004-12-15*: [pdumpfs 1.3](#download)を公開
    *   Windows 用のエラーメッセージを修正しました
*   *2004-08-11*: [pdumpfs 1.2](#download)を公開
    *   --quiet (-q), --dry-run (-n) オプションを追加
    *   最後のバックアップは 31日前までしか探さない、という制限をはずしました
    *   最後のバックアップへのシンボリックリンク latest を作るようにしました
    *   その他、細かい修正をいくつか
*   *2004-07-13*: [pdumpfs 1.1](#download)を公開
    *   エラーメッセージの表示に関するバグを修正しました
    *   その他、細かい修正をいくつか
*   *2004-06-22*: [pdumpfs 1.0](#download) を公開
    *   [Windows 用の GUI](#gui) に対応しました。 [VisualuRuby](http://www.osk.3web.ne.jp/~nyasu/software/vrproject.html) を利用しています
*   *2001-02-19*: [pdumpfs 0.1](#download) を公開

## Windows 用の GUI

[![screenshot](images/pdumpfs-ja-mini.png)](images/pdumpfs-ja.png)

Windowx XP上のスクリーンショットです。

## 必要なもの

*   [Ruby](http://www.ruby-lang.org/) 1.8.1 以上

## インストール

pdumpfs をソースからインストールするには、パッケージを展開して`make` を実行し、でき上がった `pdumpfs` ファイルを `/usr/local/bin` などにコピーします。

## 使い方

### コマンドライン

```
   % pdumpfs <対象ディレクトリ> <バックアップ先>
```

### 使用例

自分のホームディレクトリ /home/yourname を /backup にバックアップするには次のように実行します。

```
   % pdumpfs /home/yourname /backup >/backup/log 2>/backup/error-log
```

2日目以降のバックアップは cron で行うといいでしょう。毎朝 5 時にバックアップを行うには crontab に次のような設定を記述します。

```
    00 05 * * * pdumpfs /home/yourname /backup >/backup/log 2>/backup/error-log
```

毎日のバックアップが順調に進むと、 /backup/2001/02/19/yourname/... のようなファイル名で過去のファイルにアクセスできます。

### 特定ファイルの除外

特定のファイルをバックアップから除外するには以下のオプションを用います。

**--exclude=PATTERN**
:   PATTERN (Ruby の正規表現) にマッチするファイルまたはディレクトリをバックアップ対象から除外する。複数個を指定可能。 パターンマッチは、コマンドライン引数に渡した「対象ディレクトリ」が相対パスならそれを含んだ相対パス、絶対パスなら絶対パスに対して行われます。

**--exclude-by-size=SIZE**
:   SIZE 以上のサイズのファイルをバックアップ対象から除外する。 1000, 100K, 10M, 1G のような単位の指定が可能。

**--exclude-by-glob=GLOB**
:   GLOB にマッチするファイルをバックアップ対象から除外する。ファイル名の比較には、ファイルのベースネームに対して fnmatch(3) (シェルのワイルドカード) を利用します。 複数個を指定可能。

#### 例

```
# spool か log にマッチするファイル/ディレクトリをバックアップしない
% pdumpfs --exclude 'spool|log' /var /mnt/backup

# 10MB 以上のファイルをバックアップしない
% pdumpfs --exclude-by-size 10M ~/ /mnt/backup

# wave file (*.wav) をバックアップしない
% pdumpfs --exclude-by-glob "*.wav" ~/ /mnt/backup
```

## 制限事項

*   pdumpfs は通常のファイル、ディレクトリ、およびシンボリックリンクのみに対応しています。特殊なデバイスファイルなどは扱えません
*   巨大なファイルを頻繁に追加・更新するディレクトリに対しては向いてません
*   pdumpfs を運用すると、過去のファイルをいつでも取り戻せるので、不要になったファイルを気軽に削除することができます。しかし、過信は禁物です。pdumpfsには重大なバグがあるかもしれません

## 豆知識

*   1日あたり 10 MB ずつファイルが追加・更新されるとして、1年で4 GB くらいディスク消費が増える計算です。近年の計算機事情を考えれば、このくらいは平気でしょう
*   バックアップは物理的に異なるデバイスに取りましょう
*   Linux の ext2/ext3 ファイルシステムでは chattr コマンドでファイルを変更不可能(immutable) にすることができます。 /backup 以下のすべてのファイルを変更不可能にするには root 権限で `chattr -R +i /backup` と実行します。chattr コマンドを使えば、バックアップをうっかり rm -rf してしまうという被害を予防できます

## ダウンロード

[GNU General Public License version 2](http://www.gnu.org/copyleft/gpl.html) ([日本語訳](http://www.sra.co.jp/public/doc/gnu/gpl-2j.txt))に従ったフリーソフトウェアとして公開します。 完全に無保証です。

*   [pdumpfs-1.3.tar.gz](pdumpfs-1.3.tar.gz)
*   [pdumpfs-w32-1.3.zip](pdumpfs-w32-1.3.zip) (Windows 用バイナリ)
*   [CVS](http://sourceforge.net/cvs/?group_id=111004)

## 関連リンク集

*   [横着プログラミング 第8回: pdumpfs: 毎日のスナップショットを保存する](http://namazu.org/~satoru/unimag/8/)
    Unix Magazine 2002年9月号に書いた記事です
*   [pdumpfsによる定期バックアップのススメ](http://namazu.org/~satoru/pub/sd-2003-08/)
    Software Design 2003年8月号に書いた記事です
*   [mdumpfs](http://www.misuzilla.org/dist/net/mdumpfs/)
    .NET Framework を使って書かれた pdumpfs と同様のツール。Windows 用
*   [glasstree](http://www.igmus.org/code/)
    Perl で書かれた pdumpfs と同様のツール
*   [freshmeat.net: pdumpfs](http://freshmeat.net/projects/pdumpfs/)

---

[Satoru Takabayashi](http://namazu.org/~satoru/)

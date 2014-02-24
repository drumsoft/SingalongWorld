# Singalong World

* 「世界中のみんなが同じ歌をうたう声」に囲まれる疑似体験ができるiPhoneアプリです。
* 同じ曲のアマチュアによるカバーを SoundCloud から集めて、それぞれのユーザの住んでいる方角から同時に再生します。
* ヘッドホンが必要です。
* Music Hack Day Tokyo 2014 参加作品。審査員賞を頂きました。ありがとうございます。
* Xcode 5.0.2 と iPhone5 でテストしています。

* This is an iPhone App provides simulated experience to be surrounded by the "voices of the people around the world sings the same song." 
* This App collects amateur vocal covers of the same song from SoundCloud and play their vocals simultaneously from the direction that they live in.
* Headphone required.
* Awarded the jury's award in Music Hack Day Tokyo 2014. Thankyou.
* tested with Xcode 5.0.2 and iPhone5.


## Build and Play

* Xcode で ビルド - Run します。
* ヘッドホンをつけて、iPhoneを体の前に縦に構えて、立った姿勢で使ってください。
* 世界的に有名な楽曲の名前を Title 欄に入れて GO! ボタンで検索して下さい。（すこし時間がかかります）
    * 楽曲の例: "Call Me Maybe", "Tsukema Tsukeru" など
* 音楽が聴こえて来たら、その場でiPhoneを持ったまま、身体ごといろんな方向を向きましょう。世界中の同じ歌を歌う仲間が見つかります。

* Build and Run this App with Xcode.
* Wear the headphones, held the iPhone vertically in front of your body and use this App a standing position.
* Put a world-famous song title in the Title field. Push GO! button and search. (It will take some seconds.)
    * example: "Call Me Maybe", "Tsukema Tsukeru" etc...
* When the music came hear, let's face the various direction with your whole body, while holding the iPhone. You'll find fellows sing together around the world .


## Explanation

* SoundCloud API で検索+ユーザ情報取得+ストリーミングデータ取得を行い、検索結果の一斉再生を行います。ユーザ情報に基づいて仮想空間中に音源を配置し、「ユーザの住んでる国・地域の方向から」ユーザの歌声が聴こえてきます。

* This App perform search, fetch user details and grab streaming data from SoundCloud using SoundCloud API. and playback them simultaneous. Based on the user detail metadata, each sound sources are placed in virtual space and simulates that their voices come from the direction of their country.

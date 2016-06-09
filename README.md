# Gamble Market

<준비>
0. git pull

1. gem은 최소한으로 썼는데, rack은 설치해야 해요.

$> gem install rack

2. data 폴더에 players.csv라는 이름으로 파일 미리 만들어두세요. 안 그러면 실행 안 될 수 있음. (서버 붙이면서, 파라미터 받는 게 문제가 좀 생겨서 고정시켰어요.)

<실행>
1. 그래프: ‘rackup’을 입력하면 로컬 서버가 구동돼요. 주소는

http://localhost:9292

말한 대로 사람수를 누적해서 표시했음.

2. 시뮬레이션을 돌리려면, 서버와는 상관없고, 

$> ruby run.rb

입력하면 log 폴더에 결과 생성돼요.

<진행 순서>

1. 마켓은 제품(goods)별로 독립적
2. 플레이어 명단을 섞는다(shuffle).
3. wtp와 wta를 번갈아 진행한다.

더 필요한 기능이나 리포트가 있으면 알려줘요.

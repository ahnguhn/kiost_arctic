# Arctic 데이터 뷰어 — MapLibre 극좌표 3단 화면

북극 중심 극사영(NSIDC Polar Stereographic North, **EPSG:3413**) 지도 위에
utils 파이프라인 산출 **COG** 를 그려 보는 데이터 목록 뷰어.

## 실행

`run_web.bat` 더블클릭 → 브라우저가 `http://localhost:8000` 으로 열린다.

- COG/JSON 을 `fetch` 로 읽기 때문에 **file:// 로 직접 열면 동작하지 않는다.**
- `run_web.bat` 은 `range_server.py`(HTTP Range 지원 서버) 를 띄운다.
  Range 지원 덕분에 큰 COG 도 필요한 부분(오버뷰)만 읽어 로딩이 빠르다.
  (Range 미지원 서버에서도 전체 파일 다운로드 폴백으로 동작은 한다.)

## 화면 구성

```
┌──────────────┬──────────────────────┬──────────────┐
│ 데이터 리스트 │                      │ 데이터 설명   │
│  (그룹별)     │      지도 (3413)     │  표 + 비고    │
├──────────────┤                      │  대표 PNG     │
│ 그리기 목록   │                      │              │
│ [그리기]      │                      │              │
│ [모두 지우기] │                      │              │
└──────────────┴──────────────────────┴──────────────┘
```

- **왼쪽 상단 — 데이터 리스트**: 제품 그룹별 목록. 항목 클릭 → 오른쪽 설명 표시,
  `＋` 버튼(또는 더블클릭) → 아래 그리기 목록에 추가.
- **왼쪽 하단 — 그리기 목록**: 중복 추가 안 됨, 드래그&드롭으로 순서 변경,
  `×` 로 개별 제거(지도에서도 제거), `👁/🚫` 로 레이어별 **보이기/보이지 않기** 토글.
  **그리기** = 목록 순서대로 지도에 COG 를 그림(뒤가 위).
  **모두 지우기** = 지도 레이어와 목록을 모두 비움.
- **가운데 — 지도**: EPSG:3413 극사영(가상좌표 매핑), 육지/위경도망/국가명,
  파이프라인 다운로드 **권역 5개**(ARC/BRS/ENS/YLS/EAS) 경계·라벨 표시,
  우하단에 마우스 실좌표 표시. 권역선은 항상 래스터 위에 유지된다.
- **오른쪽 — 데이터 설명**: 선택한 데이터의 설명 표(원격탐사해빙자료 PPT 기반),
  비고, 대표 PNG(클릭 시 원본).

## 데이터 연결 (JSON)

| 파일 | 내용 |
|---|---|
| `data/catalog.json` | 그릴 데이터 목록. 항목별 `id, group, name, cog, png, kind(...)` |
| `data/descriptions.json` | id별 설명(`title, fields, note, caption`) — 설명 자료만 별도 관리 |

- `cog` / `png` 경로는 `web/` 기준 상대경로 (`Data_Out/...`).
- `kind: "palette"` — byte COG. 파일에 내장된 GDAL ColorTable 이 있으면 그대로,
  없으면 `enc`/`vmin`/`vmax`/`lut` 로 파이프라인과 동일한 색상 테이블을
  클라이언트에서 생성해 적용 (0 = nodata 투명).
  `enc: "percent"`(byte 1..100 = 0..100 %), `"linear"`(byte 1..255 = vmin..vmax),
  `"classes"`(byte = 클래스값+1, TSI 클래스 색상),
  `"values"`(값별 지정 색 — VNP29 이진: 해빙 100=빨강, 개수면 1=파랑).
  `override: true` 면 COG 내장 팔레트보다 catalog 색을 우선 적용.
- `kind: "float"` — Float32 COG. `lut`(freeboard/thermal/ice/gray) 와
  `stretch`([2,98] 백분위) 로 색을 입힘. nodata(-9999 등) 투명.
- `maxPx` — 큰 자료의 오버뷰 선택 상한(기본 1100).

데이터를 추가하려면 catalog.json 에 항목을 넣고, 같은 id 로
descriptions.json 에 설명을 넣으면 된다.

## 파일

```
web/
├── index.html            뷰어 본체 (투영·COG 렌더 코드 포함)
├── run_web.bat           로컬 서버 실행
├── range_server.py       HTTP Range 지원 정적 서버
├── lib/maplibre-gl.js    MapLibre GL JS 4.7.1
├── lib/maplibre-gl.css
├── lib/geotiff.js        geotiff.js (브라우저 COG 리더)
├── data/catalog.json     데이터 경로 카탈로그
├── data/descriptions.json 데이터 설명
├── data/land_data.js     Natural Earth 육지 (JS 내장)
└── Data_Out/             파이프라인 산출 COG·PNG
```

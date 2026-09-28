#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
edu_gemini 정규+심화 36장 완성형 고품질 파워포인트 빌더 (make_ppt.py)
6종 맞춤 시각 레이아웃 적용:
  1. layout_hero (타이틀/인트로)
  2. layout_compare (좌우 2열 대조: ✕ vs ✓)
  3. layout_code (다크 코드 박스 + 우측 해설/함정 카드)
  4. layout_table (데이터 매트릭스 표)
  5. layout_banner (거대 경고/원리 배너)
  6. layout_grid (3~4열 수평 카드 그리드)
"""
import os, sys
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

WIDTH = Inches(13.333)
HEIGHT = Inches(7.5)

# 테마 컬러
C_BG = RGBColor(15, 23, 42)          # Slate 900
C_CARD_BG = RGBColor(30, 41, 59)     # Slate 800
C_CARD_BORDER = RGBColor(51, 65, 85) # Slate 700
C_TEXT_MAIN = RGBColor(248, 250, 252)# White/Slate 50
C_TEXT_MUTED = RGBColor(148, 163, 184)# Slate 400
C_ACCENT = RGBColor(56, 189, 248)    # Sky 400
C_AMBER = RGBColor(251, 191, 36)     # Amber 400
C_RED = RGBColor(248, 113, 113)      # Red 400
C_RED_BG = RGBColor(69, 10, 10)      # Red 950
C_GREEN = RGBColor(74, 222, 128)     # Green 400
C_GREEN_BG = RGBColor(5, 46, 22)     # Green 950
C_CODE_BG = RGBColor(10, 15, 29)     # Dark Monospace BG

def set_slide_background(slide):
    bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, WIDTH, HEIGHT)
    bg.fill.solid()
    bg.fill.fore_color.rgb = C_BG
    bg.line.color.rgb = C_BG
    return bg

def add_header(slide, tag, title, subtitle=None):
    tag_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.5), Inches(11.7), Inches(0.4))
    tf_tag = tag_box.text_frame
    tf_tag.word_wrap = True
    p_tag = tf_tag.paragraphs[0]
    p_tag.text = tag.upper()
    p_tag.font.size = Pt(13)
    p_tag.font.bold = True
    p_tag.font.color.rgb = C_ACCENT

    title_box = slide.shapes.add_textbox(Inches(0.8), Inches(0.9), Inches(11.7), Inches(0.8))
    tf_title = title_box.text_frame
    tf_title.word_wrap = True
    p_title = tf_title.paragraphs[0]
    p_title.text = title
    p_title.font.size = Pt(26)
    p_title.font.bold = True
    p_title.font.color.rgb = C_TEXT_MAIN

    if subtitle:
        sub_box = slide.shapes.add_textbox(Inches(0.8), Inches(1.7), Inches(11.7), Inches(0.5))
        tf_sub = sub_box.text_frame
        tf_sub.word_wrap = True
        p_sub = tf_sub.paragraphs[0]
        p_sub.text = subtitle
        p_sub.font.size = Pt(14)
        p_sub.font.color.rgb = C_TEXT_MUTED

def layout_hero(prs, tag, title, subtitle, bullets):
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_background(slide)
    
    t_box = slide.shapes.add_textbox(Inches(1.0), Inches(1.2), Inches(11.3), Inches(2.2))
    tf = t_box.text_frame
    tf.word_wrap = True
    p0 = tf.paragraphs[0]
    p0.text = tag.upper()
    p0.font.size = Pt(16)
    p0.font.bold = True
    p0.font.color.rgb = C_ACCENT
    p0.space_after = Pt(12)
    
    p1 = tf.add_paragraph()
    p1.text = title
    p1.font.size = Pt(36)
    p1.font.bold = True
    p1.font.color.rgb = C_TEXT_MAIN
    p1.space_after = Pt(14)
    
    p2 = tf.add_paragraph()
    p2.text = subtitle
    p2.font.size = Pt(17)
    p2.font.color.rgb = C_TEXT_MUTED

    col_w = Inches(3.6)
    gap = Inches(0.25)
    for i, b in enumerate(bullets[:3]):
        left = Inches(1.0) + i * (col_w + gap)
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, Inches(4.3), col_w, Inches(2.3))
        card.fill.solid()
        card.fill.fore_color.rgb = C_CARD_BG
        card.line.color.rgb = C_CARD_BORDER
        
        c_box = slide.shapes.add_textbox(left + Inches(0.2), Inches(4.5), col_w - Inches(0.4), Inches(1.9))
        c_tf = c_box.text_frame
        c_tf.word_wrap = True
        cp = c_tf.paragraphs[0]
        cp.text = f"FEATURE 0{i+1}"
        cp.font.size = Pt(12)
        cp.font.bold = True
        cp.font.color.rgb = C_AMBER
        cp.space_after = Pt(8)
        
        cp2 = c_tf.add_paragraph()
        cp2.text = b
        cp2.font.size = Pt(14)
        cp2.font.color.rgb = C_TEXT_MAIN

def layout_compare(prs, tag, title, subtitle, bad_title, bad_points, good_title, good_points):
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_background(slide)
    add_header(slide, tag, title, subtitle)

    card_y = Inches(2.4)
    card_h = Inches(4.5)
    card_w = Inches(5.6)
    
    # 좌측: 나쁜 예
    left_x = Inches(0.8)
    bad_card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left_x, card_y, card_w, card_h)
    bad_card.fill.solid()
    bad_card.fill.fore_color.rgb = C_RED_BG
    bad_card.line.color.rgb = C_RED
    bad_card.line.width = Pt(1.5)

    b_box = slide.shapes.add_textbox(left_x + Inches(0.3), card_y + Inches(0.3), card_w - Inches(0.6), card_h - Inches(0.6))
    btf = b_box.text_frame
    btf.word_wrap = True
    bp = btf.paragraphs[0]
    bp.text = f"✕  {bad_title}"
    bp.font.size = Pt(18)
    bp.font.bold = True
    bp.font.color.rgb = C_RED
    bp.space_after = Pt(14)
    for pt in bad_points:
        p = btf.add_paragraph()
        p.text = f"• {pt}"
        p.font.size = Pt(14)
        p.font.color.rgb = C_TEXT_MAIN
        p.space_after = Pt(8)

    # 우측: 좋은 예
    right_x = Inches(6.9)
    good_card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, right_x, card_y, card_w, card_h)
    good_card.fill.solid()
    good_card.fill.fore_color.rgb = C_GREEN_BG
    good_card.line.color.rgb = C_GREEN
    good_card.line.width = Pt(1.5)

    g_box = slide.shapes.add_textbox(right_x + Inches(0.3), card_y + Inches(0.3), card_w - Inches(0.6), card_h - Inches(0.6))
    gtf = g_box.text_frame
    gtf.word_wrap = True
    gp = gtf.paragraphs[0]
    gp.text = f"✓  {good_title}"
    gp.font.size = Pt(18)
    gp.font.bold = True
    gp.font.color.rgb = C_GREEN
    gp.space_after = Pt(14)
    for pt in good_points:
        p = gtf.add_paragraph()
        p.text = f"• {pt}"
        p.font.size = Pt(14)
        p.font.color.rgb = C_TEXT_MAIN
        p.space_after = Pt(8)

def layout_code(prs, tag, title, subtitle, code_lang, code_text, note_title, note_points):
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_background(slide)
    add_header(slide, tag, title, subtitle)

    card_y = Inches(2.4)
    card_h = Inches(4.5)
    
    code_w = Inches(6.8)
    code_card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), card_y, code_w, card_h)
    code_card.fill.solid()
    code_card.fill.fore_color.rgb = C_CODE_BG
    code_card.line.color.rgb = C_CARD_BORDER
    
    c_box = slide.shapes.add_textbox(Inches(1.0), card_y + Inches(0.2), code_w - Inches(0.4), card_h - Inches(0.4))
    ctf = c_box.text_frame
    ctf.word_wrap = True
    cp0 = ctf.paragraphs[0]
    cp0.text = f"SOURCE [{code_lang.upper()}]"
    cp0.font.size = Pt(11)
    cp0.font.bold = True
    cp0.font.color.rgb = C_ACCENT
    cp0.space_after = Pt(10)
    
    for line in code_text.strip().split("\n"):
        p = ctf.add_paragraph()
        p.text = line
        p.font.size = Pt(12)
        p.font.name = "Consolas"
        p.font.color.rgb = C_TEXT_MAIN

    note_w = Inches(4.6)
    note_x = Inches(7.9)
    note_card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, note_x, card_y, note_w, card_h)
    note_card.fill.solid()
    note_card.fill.fore_color.rgb = C_CARD_BG
    note_card.line.color.rgb = C_AMBER
    note_card.line.width = Pt(1.5)

    n_box = slide.shapes.add_textbox(note_x + Inches(0.3), card_y + Inches(0.3), note_w - Inches(0.6), card_h - Inches(0.6))
    ntf = n_box.text_frame
    ntf.word_wrap = True
    np = ntf.paragraphs[0]
    np.text = f"⚠️  {note_title}"
    np.font.size = Pt(17)
    np.font.bold = True
    np.font.color.rgb = C_AMBER
    np.space_after = Pt(14)

    for pt in note_points:
        p = ntf.add_paragraph()
        p.text = f"• {pt}"
        p.font.size = Pt(14)
        p.font.color.rgb = C_TEXT_MAIN
        p.space_after = Pt(10)

def layout_table(prs, tag, title, subtitle, headers, rows):
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_background(slide)
    add_header(slide, tag, title, subtitle)

    table_x = Inches(0.8)
    table_y = Inches(2.5)
    table_w = Inches(11.7)
    table_h = Inches(4.3)

    num_rows = len(rows) + 1
    num_cols = len(headers)
    table_shape = slide.shapes.add_table(num_rows, num_cols, table_x, table_y, table_w, table_h)
    table = table_shape.table

    for c_idx, h_text in enumerate(headers):
        cell = table.cell(0, c_idx)
        cell.text = h_text
        cell.fill.solid()
        cell.fill.fore_color.rgb = RGBColor(30, 58, 138)
        p = cell.text_frame.paragraphs[0]
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = C_TEXT_MAIN
        p.alignment = PP_ALIGN.CENTER

    for r_idx, row in enumerate(rows):
        for c_idx, val in enumerate(row):
            cell = table.cell(r_idx + 1, c_idx)
            cell.text = str(val)
            cell.fill.solid()
            cell.fill.fore_color.rgb = C_CARD_BG if r_idx % 2 == 0 else RGBColor(23, 37, 60)
            p = cell.text_frame.paragraphs[0]
            p.font.size = Pt(13)
            p.font.color.rgb = C_TEXT_MAIN
            if "통과" in str(val) or "allow" in str(val).lower() or "성공" in str(val):
                p.font.color.rgb = C_GREEN
                p.font.bold = True
            elif "차단" in str(val) or "deny" in str(val).lower() or "실패" in str(val) or "위험" in str(val):
                p.font.color.rgb = C_RED
                p.font.bold = True

def layout_banner(prs, tag, title, big_quote, explain_title, explain_points, is_red=True):
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_background(slide)
    add_header(slide, tag, title)

    card_y = Inches(2.3)
    card_h = Inches(4.6)
    card_w = Inches(11.7)

    border_color = C_RED if is_red else C_AMBER
    bg_color = C_RED_BG if is_red else RGBColor(45, 30, 5)

    banner = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), card_y, card_w, card_h)
    banner.fill.solid()
    banner.fill.fore_color.rgb = bg_color
    banner.line.color.rgb = border_color
    banner.line.width = Pt(2.0)

    b_box = slide.shapes.add_textbox(Inches(1.2), card_y + Inches(0.4), card_w - Inches(0.8), card_h - Inches(0.8))
    tf = b_box.text_frame
    tf.word_wrap = True

    p0 = tf.paragraphs[0]
    p0.text = "CORE PRINCIPLE"
    p0.font.size = Pt(14)
    p0.font.bold = True
    p0.font.color.rgb = border_color
    p0.space_after = Pt(10)

    p1 = tf.add_paragraph()
    p1.text = big_quote
    p1.font.size = Pt(32)
    p1.font.bold = True
    p1.font.color.rgb = C_TEXT_MAIN
    p1.space_after = Pt(18)

    p2 = tf.add_paragraph()
    p2.text = f"■  {explain_title}"
    p2.font.size = Pt(16)
    p2.font.bold = True
    p2.font.color.rgb = border_color
    p2.space_after = Pt(8)

    for pt in explain_points:
        p = tf.add_paragraph()
        p.text = f"•  {pt}"
        p.font.size = Pt(14)
        p.font.color.rgb = C_TEXT_MAIN
        p.space_after = Pt(6)

def layout_grid(prs, tag, title, subtitle, cards):
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_background(slide)
    add_header(slide, tag, title, subtitle)

    n = len(cards)
    gap = Inches(0.2)
    total_w = Inches(11.7)
    card_w = (total_w - (gap * (n - 1))) / n
    card_y = Inches(2.4)
    card_h = Inches(4.5)

    for i, card_info in enumerate(cards):
        left = Inches(0.8) + i * (card_w + gap)
        c_shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, left, card_y, card_w, card_h)
        c_shape.fill.solid()
        c_shape.fill.fore_color.rgb = C_CARD_BG
        c_shape.line.color.rgb = C_CARD_BORDER

        tb = slide.shapes.add_textbox(left + Inches(0.2), card_y + Inches(0.25), card_w - Inches(0.4), card_h - Inches(0.5))
        tf = tb.text_frame
        tf.word_wrap = True

        p0 = tf.paragraphs[0]
        p0.text = f"STEP 0{i+1}" if "step" not in card_info["title"].lower() else card_info["title"]
        p0.font.size = Pt(12)
        p0.font.bold = True
        p0.font.color.rgb = C_ACCENT
        p0.space_after = Pt(6)

        p1 = tf.add_paragraph()
        p1.text = card_info["title"]
        p1.font.size = Pt(17)
        p1.font.bold = True
        p1.font.color.rgb = C_TEXT_MAIN
        p1.space_after = Pt(10)

        for pt in card_info["points"]:
            p = tf.add_paragraph()
            p.text = f"• {pt}"
            p.font.size = Pt(13)
            p.font.color.rgb = C_TEXT_MUTED
            p.space_after = Pt(6)

def layout_bullets(prs, tag, title, subtitle, bullets):
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    set_slide_background(slide)
    add_header(slide, tag, title, subtitle)

    card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(0.8), Inches(2.4), Inches(11.7), Inches(4.5))
    card.fill.solid()
    card.fill.fore_color.rgb = C_CARD_BG
    card.line.color.rgb = C_CARD_BORDER

    tb = slide.shapes.add_textbox(Inches(1.2), Inches(2.7), Inches(10.9), Inches(3.9))
    tf = tb.text_frame
    tf.word_wrap = True

    for idx, b in enumerate(bullets):
        p = tf.add_paragraph() if idx > 0 else tf.paragraphs[0]
        p.text = "•  " + b
        p.font.size = Pt(16)
        p.font.color.rgb = C_TEXT_MAIN
        p.space_after = Pt(14)

def build_full_presentation(output_path):
    prs = Presentation()
    prs.slide_width = WIDTH
    prs.slide_height = HEIGHT

    # Slide 01: Hero
    layout_hero(prs,
        "gstack 엔지니어링 마스터",
        "AI 에이전트 스킬 아키텍처 & 런타임",
        "정규 4회차(스킬 제작) + 심화 2회차(플릿 운영) 종합 마스터 과정",
        [
            "Garry Tan의 gstack v1.91.1 원본 소스코드 기반",
            "정규 4개 + 심화 2개 = 총 6개 실습 랩 100% 쉘 검증",
            "Claude Code + Antigravity/Gemini + Codex 크로스 호스트"
        ]
    )

    # Slide 02: Grid (과정 구성도)
    layout_grid(prs,
        "종합 커리큘럼",
        "과정 구성: 정규 4회차 + 심화 2회차 로드맵",
        "단일 스킬 제작에서 62개 스킬 플릿 운영 및 메타 스킬까지 완성합니다",
        [
            {"title": "Part 1: 기초&보안", "points": ["1회차: 해부&자연어 라우팅", "2회차: PreToolUse 훅 절대 보안", "Lab 01, Lab 02"]},
            {"title": "Part 2: 워크플로", "points": ["3회차: Iron Law & 디버깅", "4회차: 템플릿 컴파일러", "Lab 03, Lab 04"]},
            {"title": "Part 3: 플릿 관제", "points": ["5회차: 62개 스킬 관제 라우터", "모델별 잔소리 오버레이", "Lab 05 (심화 1)"]},
            {"title": "Part 4: 런타임&메모리", "points": ["6회차: Degraded 모드", "스킬 자동생성 & 결정로그", "Lab 06 (심화 2)"]}
        ]
    )

    # Slide 03: Compare (헌법 vs 매뉴얼)
    layout_compare(prs,
        "기본 개념",
        "스킬의 본질: 상주 헌법 vs 동적 매뉴얼",
        "모든 지침을 시스템 프롬프트에 넣으면 컨텍스트가 붕괴합니다",
        "상주 헌법 (CLAUDE.md / GEMINI.md)",
        [
            "세션 내내 모든 요청에 상주하는 기본 법률",
            "모든 도구/규칙을 다 넣으면 기본 토큰 소모 폭증",
            "신호 대 잡음비(SNR) 저하로 모델이 중요한 규칙을 망각",
            "용도: 코딩 스타일, 프로젝트 절대 규칙"
        ],
        "동적 매뉴얼 (SKILL.md)",
        [
            "평소에는 [이름+설명]만 기억하는 On-Demand 방식",
            "사용자가 그 작업을 부를 때만 서랍에서 꺼내 펼침",
            "컨텍스트 비용 최소화 + 모델 집중도 100% 유지",
            "용도: 배포, 디버깅, PR 리뷰 등 특정 전문 업무"
        ]
    )

    # Slide 04: Code (Frontmatter)
    layout_code(prs,
        "1회차 · 스킬 해부",
        "Frontmatter: 에이전트 런타임과의 계약서",
        "--- 로 감싸진 YAML 메타데이터가 스킬의 생명주기를 결정합니다",
        "yaml",
        """---
name: commit-msg-ko
description: staged 변경을 읽고 한국어
  커밋 메시지를 제안한다. Use when asked
  to '커밋 메시지 써줘', 'write commit msg'.
allowed-tools:
  - Bash(git diff:*)
  - Bash(git status:*)
  - Read
---""",
        "권한 최소화의 원칙",
        [
            "name은 폴더명과 100% 일치해야 함",
            "description은 세션 시작 시 모델이 읽는 유일한 텍스트",
            "allowed-tools에 Edit/Write를 열어주면 모델이 코드를 멋대로 고치는 부작용 발생!",
            "오직 diff만 읽을 수 있도록 도구를 잠글 것"
        ]
    )

    # Slide 05: Banner (1원칙)
    layout_banner(prs,
        "핵심 원리 ①",
        "자연어 라우팅의 제1원칙",
        "모델은 본문을 읽기 전에\n오직 이름과 description만 보고 스킬을 고른다.",
        "카탈로그 우선 탐색 정책",
        [
            "컨텍스트 최적화를 위해 모델은 본문 마크다운을 미리 읽지 않습니다.",
            "본문이 1,000줄이어도 description이 부실하면 스킬은 영원히 열리지 않습니다.",
            "description은 단순한 설명이 아니라 '언제 나를 호출할지' 적는 트리거 조건문입니다."
        ],
        is_red=False
    )

    # Slide 06: Compare (호출되는 vs 안 되는 description)
    layout_compare(prs,
        "1회차 · 실전 라우팅",
        "호출되는 description vs 무시되는 description",
        "단어 하나 차이로 모델의 스킬 호출 여부가 완전히 갈립니다",
        "✕ 무시되는 description",
        [
            "description: 커밋 도우미",
            "무엇을 하는지만 있고, 언제 불러야 하는지가 없음",
            "사용자가 '커밋 메시지 써줘'라고 해도 모델이 연관성을 확신하지 못함",
            "결과: 본문이 훌륭해도 스킬 호출 실패"
        ],
        "✓ 100% 호출되는 description",
        [
            "description: staged 변경(git diff --cached)을 읽고 한국어 Conventional Commit 메시지를 제안한다. Use when asked to '커밋 메시지 써줘', 'write a commit message'",
            "무엇 + 상황 + 사용자의 실제 발화 키워드 명시",
            "결과: 모델이 스킬 이름을 듣지 않아도 스스로 실행"
        ]
    )

    # Slide 07: Code (최소주의 unfreeze)
    layout_code(prs,
        "1회차 · 미니멀리즘",
        "작게 시작하고, 반복될 때만 키운다",
        "gstack에서 가장 작은 스킬 unfreeze는 단 48줄입니다",
        "markdown",
        """---
name: unfreeze
description: Unfreezes the codebase...
allowed-tools:
  - Bash
---
# Unfreeze
Remove the edit lock file:
```bash
rm -f .claude/freeze-lock.json
```
Confirm lock is removed to user.""",
        "단순성의 미학",
        [
            "거대한 프롬프트로 시작하지 마라.",
            "터미널에서 자주 치는 실수 하나를 막아주는 50줄짜리 스킬부터 시작하라.",
            "본문은 군더더기 없이 실행 명령과 피드백 보고로만 구성할 것."
        ]
    )

    # Slide 08: Bullets (Lab 01 안내)
    layout_bullets(prs,
        "1회차 실습",
        "Lab 01: commit-msg-ko 스킬 제작",
        "자연어 라우팅과 최소 권한 설정을 직접 경험합니다",
        [
            "실습 경로: edu_gemini/03_workbook/lab01-routing/",
            "과제 1: '커밋 메시지 써줘'라는 말에 스스로 반응하는 description 작성",
            "과제 2: git diff만 읽고 코드는 못 고치도록 allowed-tools 최소화",
            "검증: 'git commit'을 멋대로 실행하지 않고 3가지 대안을 제시하는지 확인"
        ]
    )

    # Slide 09: Banner (2원칙: 프롬프트 vs Hook)
    layout_banner(prs,
        "핵심 원리 ②",
        "절대 보안의 제2원칙",
        "프롬프트는 부탁이고,\nHook은 강제다.",
        "보안 경계는 LLM 추론 바깥에 위치해야 한다",
        [
            "프롬프트에 '절대 .env는 건드리지 마'라고 써도, 모델이 복잡한 작업에 빠지면 지시를 잊습니다.",
            "PreToolUse Hook은 도구 실행 직전 OS 쉘에서 0.01초 만에 물리적으로 가로챕니다.",
            "확률적 모델에게 운영 보안을 부탁하지 마십시오."
        ],
        is_red=True
    )

    # Slide 10: Code (PreToolUse Hook 라이프사이클)
    layout_code(prs,
        "2회차 · Hook 아키텍처",
        "PreToolUse Hook의 라이프사이클과 JSON 프로토콜",
        "stdin으로 입력을 받고 stdout으로 결정을 반환하는 초고속 게이트",
        "bash",
        """# stdin 에서 tool_input JSON 읽기
INPUT=$(cat)

# 진짜 JSON 파서로 파일 경로 추출
FILE_PATH=$(extract_path "$INPUT")

# 위험 파일 접근 시 deny 결정 반환
if [[ "$FILE_PATH" == *".env"* ]]; then
  printf '{"hookSpecificOutput":{
    "hookEventName":"PreToolUse",
    "permissionDecision":"deny",
    "permissionDecisionReason":"비밀 파일 차단"
  }}'
  exit 0
fi
echo '{}' # 통과""",
        "로컬 게이트의 위력",
        [
            "실행 시간: 30~50ms (네트워크 지연 없음)",
            "모델의 탈옥(Jailbreak) 여부와 무관하게 차단",
            "정상 파일은 빈 객체 {}를 반환하여 0초 통과"
        ]
    )

    # Slide 11: Compare (hookSpecificOutput 함정)
    layout_compare(prs,
        "2회차 · 규격의 함정",
        "판정은 반드시 hookSpecificOutput 안에 중첩하라",
        "최상위에 판정을 두면 런타임이 무시하고 통과시켜 버립니다",
        "✕ 무시되는 잘못된 출력",
        [
            "{\"permissionDecision\": \"deny\"}",
            "치명적 함정: 런타임이 에러도 내지 않고 조용히 무시함",
            "결과: .env 수정 명령이 그대로 실행되어 버림!",
            "gstack 개발진도 디버깅에 큰 시간을 쏟았던 실제 실수"
        ],
        "✓ 올바른 프로토콜 규격",
        [
            "{\"hookSpecificOutput\": {\"permissionDecision\": \"deny\", \"permissionDecisionReason\": \"...\"}}",
            "hookSpecificOutput 키 안에 중첩되어야만 유효",
            "통과(Allow)의 정석: 빈 객체 {} 또는 빈 출력"
        ]
    )

    # Slide 12: Table (grep 버그 사례)
    layout_table(prs,
        "2회차 · 실전 버그",
        "실제 버그 사례: grep 정규식 파싱으로 뚫린 검사",
        "JSON을 정규식으로 파싱하다 발생한 보안 참사",
        ["실행된 복합 명령", "옛 grep이 추출한 CMD", "판정 결과", "취약점 사유"],
        [
            ["git commit -m \"wip\" && rm -rf /", "git commit -m \\", "통과 (위험!)", "따옴표에서 파싱이 조기 종료됨"],
            ["bash -c \"rm -rf /\"", "bash -c \\", "통과 (위험!)", "이스케이프 따옴표 누락"],
            ["node -e 'fs.unlinkSync(\".env\")'", "node -e \\", "통과 (위험!)", "내부 스크립트 따옴표 단절"],
            ["진짜 JSON 파서 (Node/Python)", "전체 JSON 구조체", "정상 차단 (안전)", "따옴표 완벽 보존"]
        ]
    )

    # Slide 13: Table (위험도 2단계 판정)
    layout_table(prs,
        "2회차 · 판정 설계",
        "위험도에 따라 판정을 나눈다: deny vs ask",
        "모든 것을 막으면 개발자는 스킬을 꺼버립니다",
        ["등급 (Tier)", "대상 명령어 예시", "결정 (Decision)", "사용자 경험"],
        [
            ["HIGH (파멸적)", "rm -rf /, git push --force origin main", "deny (즉각 차단)", "질문 없이 하드 스톱"],
            ["MEDIUM (파괴적)", "rm -r dist/, DROP TABLE, git reset --hard", "ask (승인 요청)", "사용자 팝업 대화창 띄움"],
            ["LOW (안전 예외)", "rm -rf node_modules, rm -rf .cache", "allow ({})", "0초 무저항 즉시 통과"]
        ]
    )

    # Slide 14: Grid (컴포지션 /guard)
    layout_grid(prs,
        "2회차 · 컴포지션",
        "새 코드 없이 Hook을 조합해 스킬을 만든다",
        "레고 블록처럼 조립되는 스킬 컴포지션 패턴",
        [
            {"title": "1. /careful", "points": ["파괴적 명령 감시 훅", "check-careful.sh 실행", "단독 실행 가능"]},
            {"title": "2. /freeze", "points": ["수정 디렉토리 범위 잠금", "check-freeze.sh 실행", "단독 실행 가능"]},
            {"title": "3. /guard", "points": ["새 코드 0줄", "hooks 배열에 둘 다 등록", "동시 하드 가드 작동"]}
        ]
    )

    # Slide 15: Bullets (Lab 02 안내)
    layout_bullets(prs,
        "2회차 실습",
        "Lab 02: protect-secrets 스킬 제작",
        "기밀 파일 수정을 0.01초 만에 물리적으로 쳐내는 하드 가드 구축",
        [
            "실습 경로: edu_gemini/03_workbook/lab02-hook/",
            "과제 1: .env, *.pem, *.key 파일 접근 시 deny 반환",
            "과제 2: fail-closed 백스톱 트랩(trap backstop EXIT) 구현",
            "검증: test-hook.sh 실행으로 .env 차단 및 일반 파일 통과 확인"
        ]
    )

    # Slide 16: Grid (워크플로 상태 머신)
    layout_grid(prs,
        "3회차 · 워크플로",
        "긴 작업을 통제하는 워크플로 스킬과 상태 머신",
        "단발성 프롬프트와 상태 머신 기반 워크플로의 차이",
        [
            {"title": "단발성 프롬프트", "points": ["'버그 고쳐줘' 한마디", "원인 없이 코드 찌르기", "누더기 패치 양산"]},
            {"title": "게이트웨이 상태머신", "points": ["작업을 5개 Phase로 분할", "산출물 검증 시만 통과", "코드 수정 범위 잠금"]},
            {"title": "탈출 조건 (Abort)", "points": ["3-Strike 실패 시 스톱", "AskUserQuestion 호출", "무한 루프 원천 차단"]}
        ]
    )

    # Slide 17: Banner (Iron Law)
    layout_banner(prs,
        "핵심 원리 ③",
        "디버깅의 절대 철칙",
        "NO FIXES WITHOUT\nROOT CAUSE INVESTIGATION FIRST.",
        "증상만 고치면 다음 버그를 잡기가 10배 어려워진다",
        [
            "1. 버그를 100% 재현하는 최소 테스트 스크립트 작성 전까지 코드 수정 금지.",
            "2. 소스코드 상의 정확한 근본 원인을 증명하기 전까지 코드 수정 금지.",
            "이 규칙 하나가 주니어 모델을 시니어 디버거로 바꿉니다."
        ],
        is_red=True
    )

    # Slide 18: Grid (investigate 5단계)
    layout_grid(prs,
        "3회차 · 디버깅 5단계",
        "investigate 스킬의 5단계 게이트웨이",
        "실제 프로덕션 디버깅을 지휘하는 완벽한 파이프라인",
        [
            {"title": "Phase 1: 접수", "points": ["증상 파악", "환경 격리"]},
            {"title": "Phase 2: 재현", "points": ["재현 스크립트 작성", "실패 확정"]},
            {"title": "Phase 3: 원인", "points": ["근본 원인 추적", "3-Strike 적용"]},
            {"title": "Phase 4: 수정", "points": ["외과 수술적 변경", "최소 코드 수정"]}
        ]
    )

    # Slide 19: Code (3-Strike 룰)
    layout_code(prs,
        "3회차 · 무한 루프 탈출",
        "언제 멈출지 적어 둔다: 3-Strike 중단 조건",
        "에이전트에게 탈출구(Abort Condition)를 주지 않으면 토큰이 폭발합니다",
        "markdown",
        """## Abort Conditions (When to STOP)

- **The 3-Strike Rule**: If your hypothesis fails
  to reproduce the bug 3 consecutive times:
  1. STOP immediately. Do NOT guess a 4th time.
  2. Call AskUserQuestion with:
     - 3 hypotheses tested
     - Actual outputs observed
     - Clarifying questions for user""",
        "멈추는 법을 가르쳐라",
        [
            "무한 루프를 돌며 코드를 난도질하는 것 방지",
            "컨텍스트 비용 폭탄 방지",
            "적절한 시점에 사람(Human-in-the-Loop)을 호출하는 지능적 후퇴"
        ]
    )

    # Slide 20: Bullets (Lab 03 안내)
    layout_bullets(prs,
        "3회차 실습",
        "Lab 03: module-analyst 스킬 설계",
        "Iron Law와 다단계 게이트웨이를 직접 설계합니다",
        [
            "실습 경로: edu_gemini/03_workbook/lab03-workflow/",
            "과제 1: worksheet.md 작성 (성공 기준, 중단 조건, AskUserQuestion 포맷)",
            "과제 2: 3단계(인벤토리 ➔ 의존성 ➔ 보고서) 게이트웨이 명세",
            "검증: 분석 중 코드 수정을 원천 금지하는 Iron Law 준수 확인"
        ]
    )

    # Slide 21: Compare (템플릿 컴파일러)
    layout_compare(prs,
        "핵심 원리 ④",
        "공통 블록은 한 곳에서 고친다: 템플릿 컴파일러",
        "스킬이 60개가 넘어가면 사람이 직접 편집할 수 없습니다",
        "✕ 60개 마크다운 직접 수정",
        [
            "보안 지침 변경 시 60개 파일을 일일이 수동 편집",
            "반드시 누락이나 오타 발생 (문서 드리프트)",
            "에이전트마다 서로 다른 구버전 지침 실행",
            "유지보수 불가능 상태 도달"
        ],
        "✓ 템플릿 컴파일 파이프라인 (gen.sh)",
        [
            "사람은 SKILL.md.tmpl 템플릿만 작성",
            "공통 보안 규칙(partials/common.md)을 한 곳에서 관리",
            "빌드 스크립트가 0.1초 만에 60개 SKILL.md로 컴파일",
            "마크다운도 빌드하고 버전 관리하는 소스코드"
        ]
    )

    # Slide 22: Code (gen.sh 플레이스홀더)
    layout_code(prs,
        "4회차 · 빌드 파이프라인",
        "gen.sh: 플레이스홀더 치환과 빌드 자동화",
        "0.1초 만에 60개의 스킬을 최신 표준으로 일괄 렌더링",
        "bash",
        r"""COMMON=$(cat partials/common.md)

for tmpl in src/*/SKILL.md.tmpl; do
  name=$(basename $(dirname "$tmpl"))
  content=$(cat "$tmpl")
  
  final="${content//\{\{COMMON_SAFEGUARDS\}\}/$COMMON}"
  echo "$final" > "out/$name/SKILL.md"
done""",
        "플레이스홀더 확장성",
        [
            "{{COMMON_SAFEGUARDS}}: 공통 보안 규칙 일괄 주입",
            "{{INHERIT}}: 부모 스킬의 규칙 상속",
            "외부 유출 차단(redact) 로직을 모든 스킬에 일괄 배포"
        ]
    )

    # Slide 23: Grid (점진적 로딩)
    layout_grid(prs,
        "4회차 · 컨텍스트 최적화",
        "점진적 로딩: 1,500줄을 200줄로 쪼개는 비결",
        "autoplan은 전체 1,500줄이지만 컨텍스트는 80% 아낍니다",
        [
            {"title": "메인 SKILL.md", "points": ["150줄 내외 상주", "목차 및 진행 게이트", "상태 관제탑 역할"]},
            {"title": "sections/ceo.md", "points": ["CEO 리뷰 시 로딩", "200줄 전용 가이드", "완료 후 해제"]},
            {"title": "sections/eng.md", "points": ["엔지니어링 시 로딩", "아키텍처 체크리스트", "현재 단계만 집중"]},
            {"title": "효과 (Results)", "points": ["토큰 80% 절약", "Lost in Middle 방지", "환각율 제로화"]}
        ]
    )

    # Slide 24: Compare (결정적 코드 vs LLM)
    layout_compare(prs,
        "4회차 · 역할 분담",
        "결정적인 일은 코드에, LLM은 판단에만",
        "LLM에게 크롤링 데이터 파싱이나 정규식을 맡기지 마십시오",
        "✕ LLM에게 모든 계산 맡기기",
        [
            "프롬프트: 'HTML에서 순위 30개 뽑아서 JSON으로 만들어줘'",
            "결과: 중간 번호를 건너뛰거나 순위를 지어내는 환각 발생",
            "토큰 소모 극심 + 비결정적 출력"
        ],
        "✓ 스크립트 스킬 (script.ts + LLM)",
        [
            "script.ts: Cheerio/정규식으로 0.01초 만에 100% 완벽 추출",
            "fixture: 가짜 HTML로 CI에서 무료 단위 테스트",
            "LLM: 스크립트가 뱉은 JSON을 읽고 사람에게 브리핑만 수행"
        ]
    )

    # Slide 25: Compare (무료 정적 린터 vs 유료 eval)
    layout_compare(prs,
        "4회차 · 품질 보증",
        "스킬도 테스트한다: 무료로 95%, LLM은 5%에만",
        "비싼 LLM API로 테스트하지 마십시오",
        "무료 정적 린터 (validate.sh)",
        [
            "비용: 0원 / 속도: 0.1초",
            "name 일치, description 글자수(250자), 필수 키워드 검사",
            "스킬 결함의 95%(오타, 경로 오류, YAML 깨짐)를 즉시 적발",
            "CI 빌드 파이프라인의 하드 게이트"
        ],
        "유료 LLM 리허설 (claude -p)",
        [
            "비용: API 토큰 과금 / 속도: 수초~수분",
            "정적 검증을 통과한 스킬에 한해 최종 실행",
            "모델의 실제 문제 해결력과 라우팅 정확도만 평가",
            "비용 효율 20배 향상"
        ]
    )

    # Slide 26: Grid (크로스 호스트)
    layout_grid(prs,
        "4회차 · 멀티 호스트",
        "크로스 호스트: 하나의 원본, 모든 에이전트",
        "특정 AI 벤더에 종속되지 않는 스킬 자산 구축",
        [
            {"title": "Claude Code", "points": ["~/.claude/skills/", "PreToolUse Hook 규격", "Bash 도구 바인딩"]},
            {"title": "Antigravity/Gemini", "points": [".agent/skills/", "run_command 바인딩", "워크스페이스 통합"]},
            {"title": "OpenAI Codex", "points": ["hosts/codex/", "Codex CLI 프롬프트 규격", "YAML 자동 변환"]}
        ]
    )

    # Slide 27: Bullets (Lab 04 안내)
    layout_bullets(prs,
        "4회차 실습",
        "Lab 04: skill-compiler 제작",
        "템플릿 컴파일러와 정적 린터를 직접 구축합니다",
        [
            "실습 경로: edu_gemini/03_workbook/lab04-compiler/",
            "과제 1: gen.sh로 플레이스홀더 치환 컴파일 파이프라인 완성",
            "과제 2: validate.sh로 고의 결함 픽스처(글자수 초과, 트리거 누락) 100% 차단",
            "검증: verify_all.sh 원클릭 통과 확인"
        ]
    )

    # ==========================================
    # 🌟 Part 2: 심화 과정 (Slides 28 ~ 36)
    # ==========================================

    # Slide 28: Grid (심화 인트로: 스킬 플릿으로의 도약)
    layout_grid(prs,
        "심화 과정 인트로",
        "스킬 플릿 아키텍처: 단일 스킬에서 60개 시스템으로",
        "개별 스킬 제작을 넘어, 대규모 스킬 무리를 관제하고 운영하는 엔터프라이즈 기법",
        [
            {"title": "1. 관제탑 라우터", "points": ["62개 스킬 교통정리", "오탐이 미탐보다 싸다", "Lab 05 실습"]},
            {"title": "2. 모델 오버레이", "points": ["모델별 프롬프트 결함 보정", "{{INHERIT}} 상속 래퍼", "멀티 모델 지원"]},
            {"title": "3. 런타임 프로토콜", "points": ["STATUS 런타임 시그널", "Degraded 다운그레이드", "내결함성 보장"]},
            {"title": "4. 결정 메모리", "points": ["세션 무상태성 치료", "decisions.jsonl 불변 로그", "Lab 06 실습"]}
        ]
    )

    # Slide 29: Compare (관제탑 라우터)
    layout_compare(prs,
        "5회차 [심화] · 관제탑",
        "62개 스킬의 관제탑: gstack-router",
        "스킬이 너무 많아지면 라우팅 자체도 스킬이 된다",
        "스킬 62개 직접 노출 시 한계",
        [
            "사용자의 짧은 프롬프트에 모델이 스킬을 놓침 (미탐 발생)",
            "유사한 목적의 스킬 간에 엉뚱한 스킬 선택 (오인 라우팅)",
            "세션 시작 시 카탈로그 파싱 오버헤드"
        ],
        "메타 라우터 관제탑 (/gstack-router)",
        [
            "사용자 요청을 가로채 최적의 스킬로 교통정리",
            "철학: '오탐(잘못 추천)이 미탐(놓침)보다 훨씬 싸다'",
            "공격적 라우팅으로 사용자 생산성을 극대화"
        ]
    )

    # Slide 30: Code (동적 모델 오버레이)
    layout_code(prs,
        "5회차 [심화] · 모델 오버레이",
        "동적 모델 오버레이와 {{INHERIT}} 상속 래퍼",
        "같은 스킬이라도 실행 모델마다 다른 맞춤형 잔소리를 주입합니다",
        "markdown",
        """# model-overlays/sonnet.md
{{INHERIT}}

## Model-Specific Behavioral Tuning
- Conciseness: Skip preamble. Output results directly.
- Verification: Always assert exit code 0 before next Phase.
- Tool Calls: Use Edit instead of rewriting full files.""",
        "프롬프트 상속 패턴",
        [
            "기본 스킬 소스는 순수 비즈니스 로직만 유지",
            "모델별 약점(장황함, 성급함)을 오버레이로 분리",
            "컴파일 타임에 {{INHERIT}}를 치환하여 맞춤 렌더링"
        ]
    )

    # Slide 31: Bullets (Lab 05 안내)
    layout_bullets(prs,
        "5회차 [심화 1] 실습",
        "Lab 05: meta-router 스킬 제작",
        "다중 스킬의 의도를 분석하고 분기하는 관제탑을 구축합니다",
        [
            "실습 경로: edu_gemini/03_workbook/lab05-router/",
            "과제 1: meta-router 프론트매터 및 트리거 키워드 작성",
            "과제 2: 5대 스킬 패밀리(버그, 리팩토링, 배포, 성능, 스크랩) 매트릭스 설계",
            "검증: verify_all.sh의 Lab 05 테스트 통과 확인"
        ]
    )

    # Slide 32: Grid (런타임 프로토콜 & Degraded 모드)
    layout_grid(prs,
        "6회차 [심화] · 런타임 프로토콜",
        "프로덕션 런타임: STATUS 시그널 & Degraded 모드",
        "외부 장애가 발생해도 스킬은 조용히 죽지 않고 임무를 완수합니다",
        [
            {"title": "1. STATUS 라인", "points": ["STATUS: RUNNING 출력", "현재 단계 및 진행률 가시화", "CI 백그라운드 모니터링"]},
            {"title": "2. 장애 감지", "points": ["Aside 브라우저 미실치", "포트 충돌, 네트워크 단절", "CDP 연결 실패 포착"]},
            {"title": "3. Degraded 모드", "points": ["예외 크래시 방지", "Curl/CLI 텍스트 모드로 다운그레이드", "우아한 기능 저하(Graceful)"]},
            {"title": "4. 증거 라인", "points": ["GSTACK_STEP_OK 센티널", "라벨 달린 실행 증거 수집", "결정적 신뢰 확보"]}
        ]
    )

    # Slide 33: Table (컨텍스트 2층 예산)
    layout_table(prs,
        "6회차 [심화] · 컨텍스트 예산",
        "컨텍스트 2층 예산제도: 하드 게이트 vs 소프트 게이트",
        "컨텍스트를 돈과 직결되는 물리적 한정 자원으로 다룹니다",
        ["예산 계층", "대상 컴포넌트", "검증 방식", "초과 시 처리"],
        [
            ["1층: 카탈로그 예산", "name + description (상주)", "CI 하드 게이트 (250자)", "빌드 즉각 실패 (배포 차단)"],
            ["2층: 본문 지시문", "SKILL.md 본체 + sections/", "소프트 게이트 (On-demand)", "점진적 로딩 권고 (경고)"],
            ["래칫(Ratchet) 테스트", "카탈로그 총 토큰량 (2500)", "역회전 방지 테스트", "한 번 줄인 예산은 재증가 금지"]
        ]
    )

    # Slide 34: Code (메타 스킬 skillify)
    layout_code(prs,
        "6회차 [심화] · 메타 스킬",
        "스킬을 생성하는 메타 스킬: skillify",
        "성공한 세션의 도구 실행 궤적을 재사용 가능한 영구 스킬로 자동 굳히기",
        "markdown",
        """## Skillify Workflow
1. Session Trace Extraction
   - 성공한 URL, CLI 명령, 정규식 셀렉터 추출
2. Core Code Generation
   - SKILL.md (라우팅 명세)
   - script.ts (결정적 순수 코드)
   - fixtures/ + test (단위 테스트)
3. validate.sh 통과 후 ~/.claude/skills/ 자동 등록""",
        "지식의 자산화",
        [
            "30분간의 시행착오를 1초 만에 영구 자산으로 박제",
            "환각 없는 script.ts와 fixture를 일괄 생성",
            "인간이 마크다운을 손수 쓸 필요가 없음"
        ]
    )

    # Slide 35: Code (세션 간 결정 메모리)
    layout_code(prs,
        "6회차 [심화] · 결정 메모리",
        "세션 간 결정 메모리: decisions.jsonl",
        "세션이 끝나도 '왜 그렇게 결정했는지' 기억을 잃지 않는 비결",
        "jsonl",
        """{"timestamp":"2026-09-28T10:00:00Z",
 "skill":"careful",
 "decision":"grep 대신 Node 파서 채택",
 "rationale":"따옴표 커밋 메시지 파싱 버그 방지"}

{"timestamp":"2026-09-28T11:30:00Z",
 "skill":"investigate",
 "decision":"3-Strike 중단 조건 추가",
 "rationale":"무한 루프 토큰 낭비 방어"}""",
        "기억 상실(Amnesia) 치료",
        [
            "모든 LLM 세션은 기본적으로 무상태(Stateless)",
            "decisions.jsonl은 에이전트의 외장 하드디스크",
            "새 세션의 모델이 grep으로 검색하여 과거의 결정을 즉시 계승"
        ]
    )

    # Slide 36: Grid (Lab 06 안내 & 5대 황금률)
    layout_grid(prs,
        "총정리 & 심화 실습",
        "Lab 06 실습 & 스킬 아키텍트의 5대 황금률",
        "이 5가지 원칙만 지키면 상위 1%의 AI 엔지니어입니다",
        [
            {"title": "1. 라우팅", "points": ["description이 곧 라우팅", "언제 부를지까지 명시"]},
            {"title": "2. 강제성", "points": ["프롬프트는 부탁, Hook은 강제", "위험은 하드웨어로 차단"]},
            {"title": "3. Iron Law", "points": ["원인 없는 수정 절대 금지", "3-Strike 중단 조건 필수"]},
            {"title": "4. 템플릿", "points": ["공통 블록은 한 곳에서", "gen.sh로 자동 컴파일"]},
            {"title": "5. 메모리", "points": ["세션 기억을 불변 로그로 보존", "Lab 06 완주로 실전 마스터"]}
        ]
    )

    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    prs.save(output_path)
    print(f"SUCCESS: 36 slides generated at {output_path}")

if __name__ == "__main__":
    out_file = r"D:\01_aistudy\gstack_run\edu_gemini\04_ppt\gstack-mastery.pptx"
    build_full_presentation(out_file)

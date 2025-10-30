default: all

all: ensure-homebrew ensure-gem ensure-bundler ensure-bundle-install ensure-swiftlint ensure-fastlane lint-fix download-privates fetch-certificates install-templates


# -----------------------------
# 🛠 Homebrew 설치 확인
# -----------------------------
ensure-homebrew:
	@echo "🔍 Checking for Homebrew..."
	@command -v brew >/dev/null 2>&1 && echo "✅ Homebrew already installed." || { \
		echo "🍺 Homebrew not found. Installing..."; \
		/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		echo "✅ Homebrew installed."; \
	}
	@echo ""

# -----------------------------
# 💎 RubyGems 설치 확인
# -----------------------------
ensure-gem:
	@echo "🔍 Checking for RubyGems..."
	@command -v gem >/dev/null 2>&1 && echo "✅ gem already installed." || { \
		echo "❌ gem not found. Ruby가 시스템에 설치되어 있어야 합니다."; \
		echo "➡️  macOS라면: Xcode Command Line Tools를 설치하세요 (xcode-select --install)"; \
		exit 1; \
	}
	@echo ""

# -----------------------------
# 📦 Bundler 설치 확인
# -----------------------------
ensure-bundler: ensure-gem
	@echo "🔍 Checking for Bundler..."
	@command -v bundle >/dev/null 2>&1 && echo "✅ Bundler already installed." || { \
		echo "📦 Bundler not found. Installing..."; \
		sudo gem install bundler; \
		echo "✅ Bundler installed."; \
	}
	@echo ""

# -----------------------------
# 📦 bundle install 자동 실행
# -----------------------------
ensure-bundle-install: ensure-bundler
	@if [ -f "Gemfile" ]; then \
		echo "📦 Running bundle install..."; \
		bundle check >/dev/null 2>&1 || bundle install; \
		echo "✅ Bundle install complete."; \
	else \
		echo "ℹ️  No Gemfile found. Skipping bundle install."; \
	fi
	@echo ""

# -----------------------------
# 📦 SwiftLint 설치 확인
# -----------------------------
ensure-swiftlint:
	@echo "🔍 Checking for SwiftLint..."
	@brew list swiftlint >/dev/null 2>&1 && echo "✅ SwiftLint already installed." || { \
		echo "🧹 SwiftLint not found. Installing..."; \
		brew install swiftlint; \
		echo "✅ SwiftLint installed."; \
	}
	@echo ""

# 🚨 Lint
lint:
	@echo "🧪 Running lint check..."
	@swiftlint lint --strict --quiet
	@echo ""

# 🧹 자동 수정 포함
lint-fix: ensure-swiftlint
	@echo "🧼 Running autocorrect + lint check..."
	@swiftlint autocorrect
	@swiftlint lint --strict --quiet

# -----------------------------
# 🛫 Fastlane 설치 확인
# -----------------------------
ensure-fastlane:
	@echo "🔍 Checking for fastlane..."
	@command -v fastlane >/dev/null 2>&1 && echo "✅ Fastlane already installed." || { \
		echo "🚀 Fastlane not found. Installing..."; \
		sudo gem install fastlane -NV; \
		echo "✅ Fastlane installed."; \
	}
	@echo ""

# -----------------------------
# 🔐 Private 파일 다운로드
# -----------------------------
# 🔐 private 저장소 정보
Private_Repository=team-RETI/Pindora-Private
Private_Branch=main
BASE_URL=https://raw.githubusercontent.com/$(Private_Repository)/$(Private_Branch)


# ✅ 파일 다운로드 함수 (Authorization 헤더에 Bearer 적용)
define download_file
	mkdir -p $(1) && \
	curl -H "Authorization: Bearer $(GITHUB_ACCESS_TOKEN)" -o $(1)/$(3) $(BASE_URL)/$(1)/$(3)
endef

# ✅ .env 파일 없을 경우 GitHub 토큰을 받아 저장
download-privates:
	@echo "🔐 Downloading private files..."
	@if [ ! -f .env ]; then \
		read -p "Enter your GitHub access token: " token; \
		echo "GITHUB_ACCESS_TOKEN=$$token" > .env; \
	fi
	@set -a && . .env && set +a && \
	$(MAKE) _download-privates-real
	@echo ""

# ✅ 실제 다운로드 로직 (여러 파일 추가 가능)
# $(call download_file,.,$(GITHUB_ACCESS_TOKEN),Config.xcconfig)
_download-privates-real:
	$(call download_file,Pindora/Resource,$(GITHUB_ACCESS_TOKEN),GoogleService-Info.plist)
	$(call download_file,Pindora,$(GITHUB_ACCESS_TOKEN),Info.plist)
	$(call download_file,Pindora,$(GITHUB_ACCESS_TOKEN),Config.xcconfig)
	$(call download_file,PindoraShareExtension,$(GITHUB_ACCESS_TOKEN),Info.plist)
	

# -----------------------------
# 🔐 인증서 불러오기
# -----------------------------
fetch-certificates:
	@echo "🔐 Fetching signing certificates using fastlane match..."
	@export MATCH_PASSWORD=$$(grep MATCH_PASSWORD .env | cut -d '=' -f2) && \
	bundle exec fastlane match development --readonly --app_identifier com.RETIA.Pindora,com.RETIA.Pindora.ShareExtension && \
	bundle exec fastlane match appstore --readonly --app_identifier com.RETIA.Pindora,com.RETIA.Pindora.ShareExtension
	@echo ""
	
# -----------------------------
# 🧩 Xcode 커스텀 템플릿 설치
# -----------------------------
install-templates:
	@echo "🧩 Installing Xcode custom templates..."
	@TEMPLATE_DIR="$$HOME/Library/Developer/Xcode/Templates/File Templates/Custom Templates"; \
	mkdir -p "$$TEMPLATE_DIR"; \
	cp -R ./FileTemplates/* "$$TEMPLATE_DIR"; \
	echo "✅ 템플릿이 성공적으로 설치되었습니다."


# x
# bundle exec fastlane match development \
#   --app_identifier "com.RETIA.Pindora" \
#   --force_for_new_certificates \
#   --include_all_certificates

# x
# bundle exec fastlane match appstore \
#   --app_identifier "com.RETIA.Pindora" \
#   --force_for_new_certificates \
#   --include_all_certificates

# x
# 최초 한번은 직접 실행
# fastlane match appstore --app_identifier "com.RETIA.Pindora"
# fastlane match development --app_identifier "com.RETIA.Pindora"


# [기존 인증서 재사용 방법]
# 1. cer파일을 개발자 홈페이지에서 다운
# 2. p12파일을 키체인에서 내보내기
# 3. 아래 코드 작성
# bundle exec fastlane match import \
#   --username indextrown@gmail.com \
#   --git_url https://github.com/team-RETI/Pindora-Private.git \
#   --app_identifier com.RETIA.Pindora \
#   --team_id LGX4B4WC66 \
#   --type development


# /Users/kimdonghyeon/fastlane/Pindora/development.cer
# /Users/kimdonghyeon/fastlane/Pindora/development.p12
# /Users/kimdonghyeon/fastlane/Pindora/match_Development_comRETIAPindora.mobileprovision



# bundle exec fastlane match import \
#   --username indextrown@gmail.com \
#   --git_url https://github.com/team-RETI/Pindora-Private.git \
#   --app_identifier com.RETIA.Pindora \
#   --team_id LGX4B4WC66 \
#   --type appstore

# /Users/kimdonghyeon/fastlane/Pindora/distribution.cer
# /Users/kimdonghyeon/fastlane/Pindora/distribution.p12
# /Users/kimdonghyeon/fastlane/Pindora/match_AppStore_comRETIAPindora.mobileprovision



# x
# bundle exec fastlane match development \
#   --app_identifier "com.RETIA.Pindora" \
#   --force_for_new_certificates \
#   --include_all_certificates

# x
# bundle exec fastlane match appstore \
#   --app_identifier "com.RETIA.Pindora" \
#   --force_for_new_certificates \
#   --include_all_certificates

# x
# 최초 한번은 직접 실행 
# fastlane match appstore --app_identifier "com.RETIA.Pindora"
# fastlane match development --app_identifier "com.RETIA.Pindora"


# [기존 인증서 재사용 방법]
# 1. cer파일을 개발자 홈페이지에서 다운
# 2. p12파일을 키체인에서 내보내기
# 3. 아래 코드 작성
# bundle exec fastlane match import \
#   --username indextrown@gmail.com \
#   --git_url https://github.com/team-RETI/Pindora-Private.git \
#   --app_identifier com.RETIA.Pindora \
#   --team_id LGX4B4WC66 \
#   --type development


# /Users/kimdonghyeon/fastlane/Pindora/development.cer
# /Users/kimdonghyeon/fastlane/Pindora/development.p12
# /Users/kimdonghyeon/fastlane/Pindora/match_Development_comRETIAPindora.mobileprovision



# bundle exec fastlane match import \
#   --username indextrown@gmail.com \
#   --git_url https://github.com/team-RETI/Pindora-Private.git \
#   --app_identifier com.RETIA.Pindora \
#   --team_id LGX4B4WC66 \
#   --type appstore

# /Users/kimdonghyeon/fastlane/Pindora/distribution.cer
# /Users/kimdonghyeon/fastlane/Pindora/distribution.p12
# /Users/kimdonghyeon/fastlane/Pindora/match_AppStore_comRETIAPindora.mobileprovision

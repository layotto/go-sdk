# Copyright 2021 Layotto Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

# http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# All make targets should be implemented in make/*.mk
# ====================================================================================================
# Supported Targets: (Run `make help` to see more information)
# ====================================================================================================

# This file is a wrapper around `make` so that we can force on the
# --warn-undefined-variables flag.  Sure, you can set
# `MAKEFLAGS += --warn-undefined-variables` from inside of a Makefile,
# but then it won't turn on until the second phase (recipe execution),
# and won't actually be on during the initial phase (parsing).
# See: https://www.gnu.org/software/make/manual/make.html#Reading-Makefiles

# Have everything-else ("%") depend on _run (which uses
# $(MAKECMDGOALS) to decide what to run), rather than having
# everything else run $(MAKE) directly, since that'd end up running
# multiple sub-Makes if you give multiple targets on the CLI.
.PHONY: test
test:
	go test -count=1 \
	-coverprofile=coverage.txt \
	-covermode=atomic \
	-timeout=10m \
	-short -v `go list ./... | grep -v runtime`


.PHONY: modtidy
modtidy:
	@echo "===========> Running go codes format"
	go mod tidy

.PHONY: workspace
workspace: ## check if workspace is clean and committed.
workspace: go.style

.PHONY: coverage
coverage: ## Run coverage analysis.
coverage: checker.coverage

.PHONY: go.style
go.style:
	@echo "===========> Running go style check"
	@$(MAKE) format && git status && [[ -z `git status -s` ]] || echo -e "\n${RED}Error: there are uncommitted changes after formatting all the code. ${GREEN}\nHow to fix it:${NO_COLOR} please 'make format' and then use git to commit all those changed files. "

.PHONY: checker.coverage
checker.coverage:
	@echo "===========> Coverage Analysis"
	sh script/report.sh

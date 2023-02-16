#!/bin/sh

test_description='branch tracking filter options'

. ./test-lib.sh

test_expect_success setup '
	git init --initial-branch=tracked-present r1 &&
	git -C r1 commit --allow-empty -m "Initial commit" &&
	git -C r1 branch upstream-only &&
	git -C r1 branch untracked &&
	git clone r1 r2 &&
	cd r2 &&
	git checkout -b tracked-gone &&
	git push --set-upstream origin tracked-gone &&
	git push origin :tracked-gone &&
	git branch --no-track untracked &&
	git branch downstream-only
'

test_expect_success 'all local branches' '
	git branch >actual &&
	cat >expect <<-\EOF &&
	  downstream-only
	* tracked-gone
	  tracked-present
	  untracked
	EOF
	test_cmp expect actual
'

test_expect_success 'branch --has-upstream' '
	git branch --has-upstream >actual &&
	cat >expect <<-\EOF &&
	* tracked-gone
	  tracked-present
	EOF
	test_cmp expect actual
'

test_expect_success 'branch --no-has-upstream' '
	git branch --no-has-upstream >actual &&
	cat >expect <<-\EOF &&
	  downstream-only
	  untracked
	EOF
	test_cmp expect actual
'

test_expect_success 'branch --gone' '
	git branch --gone >actual &&
	cat >expect <<-\EOF &&
	* tracked-gone
	EOF
	test_cmp expect actual
'

test_expect_success 'branch --no-gone' '
	git branch --no-gone >actual &&
	cat >expect <<-\EOF &&
	  downstream-only
	  tracked-present
	  untracked
	EOF
	test_cmp expect actual
'

test_expect_success 'branch --has-upstream --no-gone' '
	git branch --has-upstream --no-gone >actual &&
	cat >expect <<-\EOF &&
	  tracked-present
	EOF
	test_cmp expect actual
'

test_done

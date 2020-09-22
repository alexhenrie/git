#!/bin/sh

test_description='git rebase interactive with splitting'

. ./test-lib.sh

. "$TEST_DIRECTORY"/lib-rebase.sh

test_expect_success 'setup' '
	echo foo > foo &&
	echo bar > bar &&
	git add foo bar &&
	git commit -m "Initial" &&
	echo bar > foo &&
	echo foo > bar &&
	git add foo bar &&
	git commit -m "Swap"
'

test_expect_success 'split ordinary commit' '
	test_when_finished "reset_rebase" &&

	set_fake_editor &&
	FAKE_LINES="split 1" \
		git rebase -i -v HEAD^ &&
		test_write_lines y n &&

	git rev-list --count HEAD > output &&
	test "$(git rev-list --count HEAD)" = 3 &&
	test "$(git log -3 -n1 --format=%B --name-only)" = "Initial\nfoo\nbar" &&
	test "$(git log -2 -n1 --format=%B --name-only)" = "Swap\nbar" &&
	test "$(git log -2 -n1 --format=%B --name-only)" = "Swap\nfoo"
'

test_expect_success 'split root commit' '
	test_when_finished "reset_rebase" &&

	git checkout stuff^0 &&

	set_fake_editor &&
	test_must_fail env FAKE_LINES="reword 2" \
		git rebase -i -v master &&

	git checkout --theirs file-2 &&
	git add file-2 &&
	FAKE_COMMIT_MESSAGE="feature_b_reworded" git rebase --continue &&

	test "$(git log -1 --format=%B)" = "feature_b_reworded" &&
	test $(git rev-list --count HEAD) = 2
'

test_expect_success 'split merge commit'

test_done

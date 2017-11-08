.PHONY: update

update:
	carthage update --platform ios

format:
	find VelocitySDK \( -name '*.h' -o -name '*.m' \) -print0 | xargs -0 clang-format -i

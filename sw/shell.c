/** \file shell.c
 *
 * (c) 1999-20xx Martin Strubel <strubel@section5.ch>
 *
 */

#include "driver.h"
#include "shell.h"


enum t_state {
	S_UNINITIALIZED, S_NEUTRAL, S_INQUOTE, S_INWORD
};


struct tokenizer_context {
	char *buf;
	char *cur;
	char *end;
	enum t_state state;
} g_tc = {
	.buf = 0,
	.cur = 0,
	.end = 0,
	.state = S_UNINITIALIZED
};

void tokenizer_begin(struct tokenizer_context *tc, char *buffer, int size)
{
	tc->cur =
	tc->buf = buffer;
	tc->end = &buffer[size-1];
	tc->state = S_NEUTRAL;
}

Token parse(struct tokenizer_context *tc, char c)
{
	if (tc->cur == tc->end) {
		*tc->cur = '\0';
		return T_EOL;
	}
	switch (tc->state) {
		case S_NEUTRAL:
			switch (c) {
				case '\033': // ESC
					return T_ESC;
				case '\015': // CR
					return T_NL;
				case '"':
					tc->state = S_INQUOTE;
					break;
				default:
					tc->state = S_INWORD;
					*tc->cur++ = c; // Copy character
			}
			break;
		case S_INQUOTE:
			switch (c) {
				case '"':
					*tc->cur = '\0';
					return T_WORD;
				default:
					*tc->cur++ = c;
			}
			break;
		case S_INWORD:
			switch (c) {
				case '\t':
				case ' ':
					*tc->cur = '\0';
					return T_WORD;
				case '\015':
					*tc->cur = '\0';
					return T_WORD_LAST;
				default:
					*tc->cur++ = c;
			}
		default:
			break;
	}

	if (c == C_EOF) return T_EOF;
	return T_CHAR;
}


int parse_input(struct tokenizer_context *tc, Token *t)
{
	int ret;
	char buf[2];

	ret = uart_read(0, buf, 1);
	if (ret <= 0) return ret;

	*t = parse(tc, buf[0]);
	return ret;
}

int gettoken(Token *token, char *word, int size)
{
	int ret;
	Token t;
	struct tokenizer_context *tc = &g_tc;

	if (tc->state == S_UNINITIALIZED) {
		tokenizer_begin(tc, word, size);
	} else {
		ret = parse_input(tc, &t);
		if (ret > 0) {
			switch (t) {
				case T_CHAR:
				case T_NONE:
					break;
				default:
					tokenizer_begin(tc, word, size); // Restart
			}
			*token = t;
			return 0;
		} else
		if (ret < 0) return ret;
	}
	*token = T_NONE;
	return 0;
}

void tokenizer_reset(void)
{
	struct tokenizer_context *tc = &g_tc;
	tc->cur = tc->buf;
	tc->state = S_NEUTRAL;
}


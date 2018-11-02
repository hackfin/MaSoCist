typedef enum {
	T_NL,
	T_NONE,
	T_CHAR,
	T_WORD,
	T_WORD_LAST,
	T_EOF,
	T_EOL,
	T_ESC,
	T_ERR,
} Token;

typedef
enum {
	S_IDLE,
	S_INPUT,
	S_CMD,
	S_INTERACTIVE,
	S_ERROR
} MainState;

#define C_UP    'u'
#define C_DOWN  'd'
#define C_EOF  '\033'

int gettoken(Token *t, char *word, int size);
void tokenizer_reset(void);

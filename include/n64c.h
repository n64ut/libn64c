#ifndef __N64C__
#define __N64C__

typedef enum { false, true } bool;
/* Modern C code might expect these to be macros. */
# ifndef bool
#  define bool bool
# endif
# ifndef true
#  define true true
# endif
# ifndef false
#  define false false
# endif

// #define true 1
// #define false 0

#define NULL ((void *)0)
typedef char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long long int64_t;
typedef unsigned long long uint64_t;
typedef void * uintptr_t;
typedef void (*void_callback_void)(void);

#define REG_INDEX 0
#define REG_RANDOM 1
#define REG_ENTRY_LO0 2
#define REG_ENTRY_LO1 3
#define REG_CONTEXT 4
#define REG_PAGE_MASK 5
#define REG_WIRED 6
// #define REG_7
#define REG_BADVADDR 8
#define REG_COUNT 9
#define REG_ENTRY_HI 10
#define REG_COMPARE 11
#define REG_STATUS 12
#define REG_CAUSE 13
#define REG_EPC 14
#define REG_PR_ID 15
#define REG_CONFIG 16
#define REG_LL_ADDR 17
#define REG_WATCH_LO 18
#define REG_WATCH_HI 19
#define REG_XCONTEXT 20
//#define REG_21
//#define REG_22
//#define REG_23
//#define REG_24
//#define REG_25
#define REG_PERR 26
#define REG_CACHE_ERR 27
#define REG_TAG_LO 28
#define REG_TAG_HI 29
#define REG_ERROR_EPC 30
//#define REG_31


__attribute__((always_inline))
static inline void COP0Set32(uint8_t register_index, uint32_t value) {
	register_index = register_index & 0x1F;
	__asm__ __volatile__(
			"li\t%z0,%0\n\t"
			"mtc0\t%z0, %register_index\n\t"
			: : "Jr"((unsigned int)(value))
	);
}

__attribute__((always_inline))
static inline uint32_t COP0Get32(uint8_t register_index) {
	register_index = register_index & 0x1F;
	uint32_t result;
	__asm__ __volatile__(
			"mfc0\t%z0, %register_index \n\t"
			: "=r"(result)	
	);
	return result;
}

__attribute__((always_inline))
static inline uint64_t COP0Get64(uint8_t register_index) {
	register_index = register_index & 0x1F;
	uint64_t result;
	__asm__ __volatile__(					
			"dmfc0\t%z0, %register_index \n\t"
			: "=r"(result)			
	);
	return result;
}

__attribute__((always_inline))
static inline uint32_t N64Get(uint32_t address) {
	return *(volatile const uint32_t *) address;
}

__attribute__((always_inline))
static inline void N64Set(uint32_t address, uint32_t value) {	
	*(volatile uint32_t *) address = value;
}

static void SetHandler(uint32_t event, void_callback_void handler) {
	N64Set(event, (uint32_t)handler);
}

#endif // __N64C__
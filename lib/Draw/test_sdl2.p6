use SDL2::Raw;

die "couldn't initialize SDL2: { SDL_GetError }" if SDL_Init(VIDEO) != 0;

my $window = SDL_CreateWindow("Hello, world!",
        SDL_WINDOWPOS_CENTERED_MASK, SDL_WINDOWPOS_CENTERED_MASK,
        800, 600, OPENGL);
my $render = SDL_CreateRenderer($window, -1, ACCELERATED +| PRESENTVSYNC);

my $event = SDL_Event.new;

main: loop {
    SDL_SetRenderDrawColor($render, 0, 0, 0, 0);
    SDL_RenderClear($render);

    while SDL_PollEvent($event) {
        if $event.type == QUIT {
            last main;
        }
    }

    SDL_SetRenderDrawColor($render, 255, 255, 255, 255);
    SDL_RenderFillRect($render,
        SDL_Rect.new(
            2 * min(now * 300 % 800, -now * 300 % 800),
            2 * min(now * 470 % 600, -now * 470 % 600),
        sin(3 * now) * 50 + 80, cos(4 * now) * 50 + 60));

    SDL_RenderPresent($render);
}
SDL_Quit();

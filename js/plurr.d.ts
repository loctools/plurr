declare module 'plurr' {
  export default class Plurr {
    constructor(options?: { locale: string; autoPlurals?: boolean; strict?: boolean });
    setLocale(locale: string): void;
    format(
      str: string,
      params: { [key: string]: any },
      options?: { [key: string]: any }
    ): string;
  }
}

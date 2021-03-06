module scid.blas;

import std.math;
import scid.common.meta;
import scid.common.traits;
import std.traits;
import std.algorithm;
import std.conv, std.string;
import std.ascii;
//debug = blasCalls;
//version = nodeps;

debug( blasCalls ) {
	import std.stdio;
	import scid.internal.assertmessages;
}


version( nodeps ) {
	private enum bool forceNaive = true;
} else {
	private enum bool forceNaive = false;
	static import scid.bindings.blas.dblas;
	private alias scid.bindings.blas.dblas blas_;
}

// This is just to save typing since conversions from size_t to int for BLAS are all over the place.
int toi(size_t x) { return to!int(x); }

struct blas {
	static void swap( T )( size_t n, T* x, size_t incx, T* y, size_t incy ) {
		debug( blasCalls )
			writef( "swap( %s, %s ) ", stridedToString( x, n, incx ), stridedToString( y, n, incy ) );
		
		static if( isFortranType!T && !forceNaive )
			blas_.swap( toi(n), x, toi(incx), y, toi(incy) );
		else
			naive_.swap( n, x, incx, y, incy );
		
		debug( blasCalls )
			writefln( "=> ( %s, %s )", stridedToString( x, n, incx ), stridedToString( y, n, incy ) );
	}
	
	static void scal( T )( size_t n, T alpha, T* x, size_t incx ) {
		debug( blasCalls )
			write( "scal( ", alpha, ", ", stridedToString(x, n, incx), " ) => " );
		
		static if( isFortranType!T && !forceNaive )
			blas_.scal( toi(n), alpha, x, toi(incx) );
		else
			naive_.scal( n, alpha, x, incx );
		
		debug( blasCalls )
			writeln( stridedToString(x, n, incx) );
	}
	
	static void copy( T, U )( size_t n, const(T)* x, size_t incx, U* y, size_t incy ) 
	if( isConvertible!( T, U ) ) {
		debug( blasCalls )
			write( "copy( ", stridedToString(x, n, incx), ", ", stridedToString(y, n, incy), " ) => " );
		
		static if( isFortranType!T && is( Unqual!T == Unqual!U ) && !forceNaive )
			blas_.copy( toi(n), x, toi(incx), y, toi(incy) );
		else
			naive_.copy( n, x, incx, y, incy );
		
		debug( blasCalls )
			writeln( stridedToString(y, n, incy) );
	}
	
	static void axpy( T )( size_t n, T alpha, const(T)* x, size_t incx, T* y, size_t incy ) {
		debug( blasCalls )
			write( "axpy( ", alpha, ", ", stridedToString(x, n, incx), ", ", stridedToString(y, n, incy), " ) => " );
		
		static if( isFortranType!T && !forceNaive )
			blas_.axpy( toi(n), alpha, x, toi(incx), y, toi(incy) );
		else
			naive_.axpy( n, alpha, x, incx, y, incy );
		
		debug( blasCalls )
			writeln( stridedToString(y, n, incy) );
	}
	
	static T dot( T )( size_t n, const(T)* x, size_t incx, const(T)* y, size_t incy ) if( !isComplexScalar!T ) {
		debug( blasCalls )
			write( "dot( ", stridedToString(x, n, incx), ", ", stridedToString(y, n, incy), " ) => " );
		
		static if( isFortranType!T && !forceNaive )
			auto r = blas_.dot( toi(n), x, toi(incx), y, toi(incy) );
		else
			auto r = naive_.dot( n, x, incx, y, incy );
		
		debug( blasCalls )
			writeln( r );
		
		return r;
	}
	
	static T dotu( T )( size_t n, const(T)* x, size_t incx, const(T)* y, size_t incy ) if( isComplexScalar!T ) {
		debug( blasCalls )
			write( "dotu( ", stridedToString(x, n, incx), ", ", stridedToString(y, n, incy), " ) => " );
		
		static if( isFortranType!T && !forceNaive )
			auto r = blas_.dotu( toi(n), x, toi(incx), y, toi(incy) );
		else
			auto r = naive_.dot!true( n, x, incx, y, incy );
		
		debug( blasCalls )
			writeln( r );
		
		return r;
	}
	
	static T dotc( T )( size_t n, const(T)* x, size_t incx, const(T)* y, size_t incy ) if( isComplexScalar!T ) {
		debug( blasCalls )
			write( "dotc( ", stridedToString(x, n, incx), ", ", stridedToString(y, n, incy), " ) => " );
		
		static if( isFortranType!T && !forceNaive )
			auto r = blas_.dotc( toi(n), x, toi(incx), y, toi(incy) );
		else
			auto r = naive_.dotc( n, x, incx, y, incy );
		
		debug( blasCalls )
			writeln( r );
		
		return r;
	}
	
	static T nrm2( T )( size_t n, const(T)* x, size_t incx ) {
		debug( blasCalls )
			write( "nrm2( ", stridedToString(x, n, incx), " ) => " );
		
		static if( isFortranType!T && !forceNaive )
			auto r = blas_.nrm2( toi(n), x, toi(incx) );
		else
			auto r = naive_.nrm2( n, x, incx );
		
		debug( blasCalls )
			writeln( r );
	}
	
	static void gemv( char trans, T )( size_t m, size_t n, T alpha, const(T)* a, size_t lda, const(T)* x, size_t incx, T beta, T *y, size_t incy ) {
		debug( blasCalls )
			writef( "gemv( %s, %s ) ", matrixToString(trans,m,n,a, lda), stridedToString( x, n, incx ) );
		
		static if( isFortranType!T && !forceNaive )
			blas_.gemv( trans, toi(m), toi(n), alpha, a, toi(lda), x, toi(incx), beta, y, toi(incy) );
		else
			naive_.gemv!trans( m, n, alpha, a, lda, x, incx, beta, y, incy );
		
		debug( blasCalls )
			writeln("=> ", stridedToString( x, n, incx ) );
	}
	
	static void trmv( char uplo, char trans, char diag, T )( size_t n, const(T)* a, size_t lda, T* x, size_t incx ) {
		debug( blasCalls )
			writef( "trmv( %s, %s, %s, %s ) ", uplo, diag, matrixToString(trans,n,n,a, lda), stridedToString( x, n, incx ) );
		
		static if( isFortranType!T && !forceNaive )
			blas_.trmv( uplo, trans, diag, toi(n), a, toi(lda), x, toi(incx) );
		else
			naive_.trmv!( uplo, trans, diag )( n, a, lda, x, incx );
		
		debug( blasCalls )
			writeln( "=> ", stridedToString( x, n, incx ) );
	}
	
	static void sbmv( char uplo, T )( size_t n, size_t k, T alpha, const(T)* a, size_t lda, const(T)* x, size_t incx, T beta, T *y, size_t incy ) {
		debug( blasCalls )
			write( "sbmv( ", uplo, ", ", n, ", ", k, ", ", alpha, ", ", stridedToString(a,n,1), ", ", stridedToString(x,n,incx), ", ", stridedToString(y,n,incy), " ) => " );
		
		static if( isFortranType!T && !forceNaive )
			blas_.sbmv( uplo, toi(n), toi(k), alpha, a, toi(lda), x, toi(incx), beta, y, toi(incy) );
		else
			static assert( false );
			
		debug( blasCalls )
			writeln( stridedToString(y,n,incy) );
	}
	
	static void gemm( char transa, char transb, T )( size_t m, size_t n, size_t k, T alpha, const(T)* a, size_t lda, const(T) *b, size_t ldb, T beta, T *c, size_t ldc ) {
		debug( blasCalls )
			writef( "gemm( %s, %s, %s, %s, %s, %s, %s, %s, %s, %s ) =>",
				  transa, transb, m, n, k, alpha, matrixToString( transa, m, k, a, lda ),
				  matrixToString( transb, k, n, b, ldb ), beta, matrixToString( 'N', m, n, c, ldc ) );
		
		static if( isFortranType!T && !forceNaive )
			blas_.gemm( transa, transb, toi(m), toi(n), toi(k), alpha, a, toi(lda), b, toi(ldb), beta, c, toi(ldc) );
		else
			naive_.gemm!( transa, transb )( m, n, k, alpha, a, lda, b, ldb, beta, c, ldc );
		
		debug( blasCalls )
			writeln( matrixToString( 'N', m, n, c, ldc ) );
	}
	
	// Level 3
	
	static void trsm( char side, char uplo, char transa, char diag, T )( size_t m, size_t n, T alpha, const(T)* a, size_t lda, T* b, size_t ldb ) {
		debug( blasCalls )
			writef( "trsm( %s, %s, %s, %s, %s ) ", side, uplo, diag, matrixToString(transa, m, n, a, lda), matrixToString( 'n', m, n, b, ldb ) );
		
		static if( isFortranType!T && !forceNaive )
			blas_.trsm( side, uplo, transa, diag, toi(m), toi(n), alpha, a, toi(lda), b, toi(ldb) );
		else
			naive_.trsm!( side, uplo, transa, diag )( m, n, alpha, a, lda, b, ldb );
			//static assert( false, "There is no naive implementation of trsm available." );
		
		debug( blasCalls )
			writeln( matrixToString( 'n', m, n, b, ldb ) );
	}
	
	// Extended BLAS, stuff I needed and wasn't implemented by BLAS.
	
	// x := conj( x )
	static T xconj( T )( T x ) if( isComplexScalar!T ) {
		return naive_.xconj( x );
	}
	
	// x := x.H
	static void xcopyc( T )( size_t n, T* x, size_t incx ) if( isComplexScalar!T ) {
		debug( blasCalls )
			write( "xcopyc( ", stridedToString(x, n, incx), " ) => " );
		
		naive_.xcopyc( n, x, incx );
		
		debug( blasCalls )
			writeln( stridedToString(x, n, incx) );
	}
	
	// y := x.H
	static void xcopyc( T )( size_t n, const(T)* x, size_t incx, T* y, size_t incy ) if( isComplexScalar!T ) {
		debug( blasCalls )
			write( "xcopyc( ", stridedToString(x, n, incx), ", ", stridedToString(y, n, incy), " ) => " );
		
		naive_.xcopyc( n, x, incx, y, incy );
		
		debug( blasCalls )
			writeln( stridedToString(y, n, incy) );
	}
	
	// y := alpha*x.H + y
	static void xaxpyc( T )( size_t n, T alpha, const(T)* x, size_t incx, T* y, size_t incy ) if( isComplexScalar!T ) {
		debug( blasCalls )
			write( "xaxpyc( ", alpha, ", ", stridedToString(x, n, incx), ", ", stridedToString(y, n, incy), " ) => " );
		
		naive_.xcopyc( n, alpha, x, incx, y, incy );
		
		debug( blasCalls )
			writeln( stridedToString(y, n, incy) );
	}
	
	// General matrix copy
	// B := A    or
	// B := A.T  or
	// B := A.H, for A and B mxn matrices
	static void xgecopy( char transA, T, U )( size_t m, size_t n, const(T)* a, size_t lda, U* b, size_t ldb ) 
	if( isConvertible!( T, U ) ) {
		debug( blasCalls ) {
			writeln();
			writeln( "xgecopy( ", matrixToString(transA,m,n,a,lda), ", ", matrixToString('N',m,n,b,ldb), " ) => ..." );
		}
		
		naive_.xgecopy!transA( m, n, a, lda, b, ldb );
		
		debug( blasCalls ) {
			writeln( "/xgecopy()" );
			writeln();
		}
	}
	
	
	// General matrix copy
	// B := conj(A)   or
	// B := conj(A.T), for A and B mxn matrices
	static void xgecopyc( char transA, T )( size_t m, size_t n, const(T)* a, size_t lda, T* b, size_t ldb ) {
		debug( blasCalls ) {
			writeln();
			writeln( "xgecopyc( ", matrixToString(transA,m,n,a,lda), ", ", matrixToString('N',m,n,a,ldb), " ) => ..." );
		}	
		
		naive_.xgecopy!( transA, true )(  m, n, a, lda, b, ldb );
		
		debug( blasCalls ) {
			writeln( "/xgecopyc()" );
			writeln();
		}
	}
	
}

private struct naive_ {
	private static void reportNaive_() {
		debug( blasCalls )
			write( "<n> " );
	}
	
	private static bool checkMatrix( T )( char trans, size_t m, size_t n, const T* a, size_t lda ) {
		if( trans == 'T' || trans == 'C' )
			std.algorithm.swap( m, n );
		assert(trans == 'T' || (trans == 'C' && isComplexScalar!(Unqual!T))  || trans == 'N',
			   "Invalid transposition character '" ~ trans ~ "' for '" ~ T.stringof ~ ".");
		assert( a != null, "Null matrix." );
		assert( lda >= m, format("Leading dimension less than minor dimension: %d vs %d",lda,m) );
		return true;
	}
	
	private static bool checkVector( T )( T* x, size_t incx ) {
		assert( incx != 0 );
		assert( x != null );
		return true;
	}
	
	// LEVEL 1
	static void swap( T )( size_t n, T* x, size_t incx, T* y, size_t incy ) {
		debug( blasCalls ) reportNaive_();
		
		if( !n )
			return;
		
		assert( checkVector( x, incx )	);
		assert( checkVector( y, incy )	);
		
		if( incx == 1 && incy == 1 ) {
			auto xe = x + n;
			T aux;
			while( x != xe ) {
				aux = *x; *x = *y; *y = aux;
				++ x; ++ y;
			}
		} else {
			n *= incx;
			auto xe = x + n * incx;
			T aux;
			while( x != xe ) {
				aux = *x; *x = *y; *y = aux;
				x += incx; y += incy;
			}
		}
	}
	
	static void scal( T )( size_t n, T alpha, T* x, size_t incx ) {
		debug( blasCalls ) reportNaive_();
		
		if( !n || alpha == One!T )
			return;
		
		assert( checkVector( x, incx )	);
		if( incx == 1 ) {
			if( !alpha )
				x[ 0 .. n ] = Zero!T;
			else
				x[ 0 .. n ] *= alpha;
		} else if( alpha ) {
			n *= incx;
			auto xe	= x + n;
			while( x != xe ) {
				(*x) *= alpha;
				x += incx;
			}
		} else {
			n *= incx;
			auto xe	= x + n;
			while( x != xe ) {
				(*x) = Zero!T;
				x += incx;
			}
		}
	}
	
	static void copy( T , U )( size_t n, const(T)* x, size_t incx, U* y, size_t incy ) {
		debug( blasCalls ) reportNaive_();
		
		if( !n )
			return;
		
		assert( checkVector( x, incx ) );
		assert( checkVector( y, incy ) );
		
		static if( is( Unqual!T == Unqual!U ) ) {
            if( incx == 1 && incy == 1 ) {
                y[ 0 .. n ] = x[ 0 .. n ];
                return;
            }
		}
                
        n *= incx;
        auto xe = x + n;
        while( x != xe ) {
            *y = *x;
            x += incx; y += incy;
        }
	}
	
	static void axpy( T )( size_t n, T alpha, const(T)* x, size_t incx, T* y, size_t incy ) {
		debug( blasCalls ) reportNaive_();
		
		if( alpha == Zero!T || !n )
			return;
		
		assert( checkVector( y, incy )	);
		assert( checkVector( x, incx )	);
		
		if( incx == 1 && incy == 1 ) {
			y[ 0 .. n ] += x[ 0 .. n ] * alpha;
		} else {
			n *= incx;
			auto xe = x + n;
			T aux;
			while( x != xe ) {
				aux = *x; aux *= alpha;
				*y += aux;
				x += incx; y += incy;
			}
		}
	}
	
	static T dot( bool forceComplex = false, T )( size_t n, const(T)* x, size_t incx, const(T)* y, size_t incy )
				if( !isComplexScalar!T || forceComplex ) {
		debug( blasCalls ) reportNaive_();
					
		if( !n )
			return Zero!T;
				
		assert( checkVector( y, incy )	);
		assert( checkVector( x, incx )	);
		
		T r = Zero!T;
		if( incx == 1 && incy == 1 ) {
			auto xe = x + n;
			T aux;
			while( x != xe ) {
				aux = *x; aux *= *y;
				r += aux;
				++x; ++y;
			}
		} else {
			n *= incx;
			auto xe = x + n;
			T aux;
			while( x != xe ) {
				aux = *x; aux *= *y;
				r += aux;
				x += incx; y += incy;
			}
		}
		
		return r;
	}
	
	template dotu( T ) {
		alias dot!(true,T) dotu;
	}
	
	static T dotc( T )( size_t n, const(T)* x, size_t incx, const(T)* y, size_t incy ) if( isComplexScalar!T ) {
		debug( blasCalls ) reportNaive_();
		
		assert( checkVector( y, incy )	);
		assert( checkVector( x, incx )	);
		
		T r = Zero!T;
		if( incx == 1 && incy == 1 ) {
			auto xe = x + n;
			T aux;
			while( x != xe ) {
				aux = *x; aux = conj( aux );
				aux *= *y;
				r += aux;
				++x; ++y;
			}
		} else {
			n *= incx;
			auto xe = x + n;
			T aux;
			while( x != xe ) {
				aux = *x; aux = conj( aux );
				aux *= *y;
				r += aux;
				x += incx; y += incy;
			}
		}
		
		return r;
	}
	
	static T nrm2( T )( size_t n, const(T)* x, size_t incx ) {
		debug( blasCalls ) reportNaive_();
		
		assert( checkVector( x, incx )	);
		T r = Zero!T;
		T aux;
		if( incx == 1 ) {
			auto xe = x + n;
			while( x != xe ) {
				aux = *x; aux *= aux;
				r += aux;
				++ x;
			}
		} else {
			n *= incx;
			auto xe = x + n;
			while( x != xe ) {
				aux = *x; aux *= aux;
				r += aux;
				++ x;
			}
		}
		
		aux = sqrt( r );
		return aux;
	}
	
	// LEVEL 2
	static void gemv( char trans_, T )( size_t leny, size_t lenx, T alpha, const(T)* a, size_t lda, const(T)* x, size_t incx, T beta, T *y, size_t incy ) {
		enum trans = cast(char)toUpper( trans_ );
		
		debug( blasCalls ) reportNaive_();
		if( !lenx || !alpha ) {
			if( trans == 'N' )
				scal( leny, beta, y, incy );
			else
				scal( lenx, beta, y, incy );
			return;
		}
		
		assert( checkVector( y, incy ) );
		assert( checkVector( x, incx ) );
		assert( checkMatrix( trans, leny, lenx, a, lda ) );
		
		static if( trans == 'N' ) {
			foreach( i ; 0 .. leny ) {
				T temp = Zero!T;
				foreach( j ; 0 .. lenx )
					 temp += a[ j * lda + i ] * x[ j * incx ];
				temp *= alpha;
				
				y[ i * incy ] *= beta;
				y[ i * incy ] += temp;
			}
		} else {
			foreach( i ; 0 .. lenx ) {
				T temp = Zero!T;
				foreach( j ; 0 .. leny )
					 temp += a[ i * lda + j ] * x[ j * incx ];
				temp *= alpha;
				
				y[ i * incy ] *= beta;
				y[ i * incy ] += temp;
			}
		}
	}
	
	static void trmv( char uplo_, char trans_, char diag_, T)( size_t n, const(T)* a, size_t lda, T* x, size_t incx ) {
		enum uplo = cast(char)toUpper( uplo_ );
		enum trans = cast(char)toUpper( trans_ );
		enum diag = cast(char)toUpper( diag_ );
		
		static assert( uplo == 'U' || uplo == 'L' );
		static assert( trans == 'N' || trans == 'T' || ( trans == 'C' && isComplexScalar!T ) );
		static assert( diag == 'U' || diag == 'N' );
		assert( n >= 0 );
		assert( lda >= max(1, n) );
		assert( incx != 0 );
		
		if( n == 0 )
			return;
		
		static if( (uplo == 'U') ^ (trans != 'N') ) {
			// Upper No-Transpose or Lower Transposed
			foreach( j ; 0 .. n ) {
				T xj = x[ j * incx ];
				static if( trans == 'N' ) {
					if( xj != Zero!T ) {
						foreach( i ; 0 .. j )
							x[ i * incx ] += xj * a[ j * lda + i ];
						
						static if( diag == 'N' )
							x[ j * incx ] *= a[ j * lda + j ];
					}
				} else {
					static if( diag == 'N' )
						xj *= a[ j * lda + j ];
						
					foreach( i ; j + 1 .. n ) {
						static if( trans == 'C' )
							xj += blas.xconj( a[ j * lda + i ] ) * x[ i * incx ];
						else
							xj += a[ j * lda + i ] * x[ i * incx ];
					}
					
					x[ j * incx ] = xj;
				}
			 }
		} else {
			// Lower No-Transpose or Upper Transposed
			for( int j = toi(n) - 1; j >= 0 ; -- j ) {
				T xj = x[ j * incx ];
				static if( trans == 'N' ) {
					if( xj != Zero!T ) {
						for( int i = toi(n) - 1 ; i > j ; -- i )
							x[ i * incx ] += xj * a[ j * lda + i ];
						
						static if( diag == 'N' )
							x[ j * incx ] *= a[ j * lda + j ];
					}
				} else {
					static if( diag == 'N' )
						xj *= a[ j * lda + j ];
					
					for( int i = j - 1 ; i >= 0 ; -- i )
						xj += a[ j * lda + i ] * x[ i * incx ];
					
					x[ j * incx ] = xj;
				}
			}
		}
	}
	
	// Level 3
	
	static void gemm( char transa_, char transb_, T )( size_t m, size_t n, size_t k, T alpha, const(T)* a, size_t lda, const(T) *b, size_t ldb, T beta, T *c, size_t ldc ) {
		enum transa = cast(char)toUpper(transa_);
		enum transb = cast(char)toUpper(transb_);
		
		T geta( size_t i, size_t j ) {
			static if      ( transa == 'N' ) return a[ i + j * lda ];
			else static if ( transa == 'T' ) return a[ j + i * lda ];
			else static if ( transa == 'C' ) return blas.xconj( a[ j + i * lda ] );
		}
		
		T getb( size_t i, size_t j ) {
			static if      ( transb == 'N' ) return b[ i + j * ldb ];
			else static if ( transb == 'T' ) return b[ j + i * ldb ];
			else static if ( transb == 'C' ) return blas.xconj( b[ j + i * ldb ] );
		}
		
		void setc( T rhs, size_t i, size_t j ) { c[ i + j * ldc ] = rhs; }
		T getc( size_t i, size_t j ) { return c[ i + j * ldc ]; }
		
		foreach( col ; 0 .. n ) foreach( row ; 0 .. m ) {
			T x = getc( row, col ) * beta;
			T tmp = Zero!T;
			foreach( ki ; 0 .. k )	
				tmp += geta( row, ki ) * getb( ki, col );
			setc( x * beta + tmp * alpha, row, col );
		}
	}
	
	static void trsm( char side_, char uplo_, char trans_, char diag_,T )( size_t m, size_t n, T alpha, const(T)* a, size_t lda, T* b, size_t ldb ) {
		enum side = cast(char)toUpper(side_);
		enum uplo = cast(char)toUpper(uplo_);
		enum trans = cast(char)toUpper(trans_);
		enum diag = cast(char)toUpper(diag_);
		
		static assert( false, "No naive implementation of trsm available, sorry." );
	}

	// Extended
	// x := conj( x )
	static T xconj( T )( T x ) if( isComplexScalar!(Unqual!T) ) {
		static if( is( T E : Complex!E ) )
			return x.conj;
		else
			return conj( x );
	}
	
	// x := x.H
	static void xcopyc( T )( int n, T* x, int incx ) if( isComplexScalar!T ) {
		debug( blasCalls ) reportNaive_();
		
		if( !n )
			return;
		
		assert( checkVector( x, incx ) );
		
		if( incx == 1 ) {
			auto xe = x + n;
			while( x != xe ) {
				*x = xconj( *x );
				++ x;
			}
		} else {
			n *= incx;
			auto xe = x + n;
			while( x != xe ) {
				*x = xconj( *x );
				x += incx;
			}
		}
	}
	
	// y := x.H
	static void xcopyc( T, U )( size_t n, const(T)* x, size_t incx, U* y, size_t incy ) 
	if( isComplexScalar!T && isComplexScalar!U ) {
		debug( blasCalls ) reportNaive_();
		
		if( !n )
			return;
		
		assert( checkVector( x, incx ) );
		
		if( incx == 1 && incy == 1 ) {
			auto xe = x + n;
			while( x != xe ) {
				*y = xconj( *x );
				++ x; ++ y;
			}
		} else {
			n *= incx;
			auto xe = x + n;
			while( x != xe ) {
				*y = xconj( *x );
				x += incx; y += incy;
			}
		}
	}
	
	// y := alpha*x.H + y
	static void xaxpyc( T )( size_t n, T alpha, const(T)* x, size_t incx, T* y, size_t incy ) if( isComplexScalar!T ) {
		debug( blasCalls ) reportNaive_();
		
		if( !n || alpha == Zero!T )
			return;
		
		assert( checkVector( x, incx ) );
		
		T aux;
		if( incx == 1 && incy == 1 ) {
			auto xe = x + n;
			while( x != xe ) {
				aux = *x; aux = xconj( aux ) * alpha;
				*y += aux;
				++ x; ++ y;
			}
		} else {
			n *= incx;
			auto xe = x + n;
			while( x != xe ) {
				aux = *x; aux = xconj( aux ) * alpha;
				*y += aux;
				x += incx; y += incy;
			}
		}
	}
	
	// General matrix copy
	// B := A    or
	// B := A.T  or
	// B := A.H    , for A and B mxn matrices
	static void xgecopy( char transA_, bool forceConjugate=false, T, U )
	( size_t m, size_t n, const(T)* a, size_t lda, U* b, size_t ldb ) 
	if( ( isComplexScalar!T && isComplexScalar!U ) || !forceConjugate &&
    isConvertible!( T, U ) ) {
		//debug( blasCalls ) reportNaive_();
		
		enum transA = cast(char)toUpper( transA_ );
		
		if( !m || !n )
			return;
		
		assert( checkMatrix( transA, m, n, a, lda ) );
		assert( checkMatrix( 'N', m, n, b, ldb ) );
		
		static if( transA == 'N' ) {
			// if a is not transposed
			if( lda == m && ldb == m ) {
				// if there are no gaps in their memory, just copy
				// eveything
				static if( forceConjugate )
					blas.xcopyc( m * n, a, 1, b, 1 );
				else
					blas.copy( m *n, a, 1, b, 1 );
				
			} else {
				// if there are gaps, copy column-by-column
				n *= ldb;
				auto be = b + n;
				while( b != be ) {
					static if( forceConjugate )
						blas.xcopyc( m, a, 1, b, 1 );
					else
						blas.copy( m, a, 1, b, 1 );
					a += lda; b += ldb;
				}
			}
		} else static if( transA == 'T' ) {
			// if a is transposed, copy a row-by-row to b column-by-column
			n *= ldb;
			auto be = b + n;
			while( b != be ) {
				blas.copy( toi(m), a, toi(lda), b, 1 );
				++ a; b += ldb;
			}
		} else {
			static if( !isComplexScalar!(Unqual!T) ) {
				assert( false,
					"'" ~ transA ~ "', invalid value for 'transA' in matrix of type '" ~ T.stringof ~ "' copy." );
			} else {
				// assume transA == 'C'
				n *= ldb;
				auto be = b + n;
				while( b != be ) {
					blas.xcopyc( m, a, lda, b, 1 );
					++ a; b += ldb;
				}
			}
		}
	}
	
	// General matrix axpy
	// B := alpha*A   + B  or
	// B := alpha*A.T + B  or
	// B := alpha*A.H + B, for A and B mxn matrices
	static void xgeaxpy( char transA_, bool forceConjugate=false,  T )( size_t m, size_t n, T alpha, const(T)* a, size_t lda, T* b, size_t ldb ) if( isComplexScalar!T || !forceConjugate ) {
		//debug( blasCalls ) reportNaive_();
		
		enum transA = cast(char)toUpper( transA_ );
		
		if( !m || !n )
			return;
		
		assert( checkMatrix( transA, m, n, a, lda ) );
		assert( checkMatrix( 'N', m, n, b, ldb ) );
		
		if( transA == 'N' ) {
			// if a is not transposed
			if( lda == m && ldb == m ) {
				// if there are no gaps in their memory, just copy
				// eveything
				static if( forceConjugate )
					blas.xaxpyc( m * n, alpha, a, 1, b, 1 );
				else
					blas.axpy( m * n, alpha, a, 1, b, 1 );
				
			} else {
				// if there are gaps, copy column-by-column
				n *= ldb;
				auto be = b + n;
				while( b != be ) {
					static if( forceConjugate )
						blas.xaxpyc( m, alpha, a, 1, b, 1 );
					else
						blas.axpy( m, alpha, a, 1, b, 1 );
					a += lda; b += ldb;
				}
			}
		} else if( transA == 'T' ) {
			// if a is transposed, copy a row-by-row to b column-by-column
			n *= ldb;
			auto be = b + n;
			while( b != be ) {
				blas.axpy( m, alpha, a, lda, b, 1 );
				++ a; b += ldb;
			}
		} else {
			static if( !isComplexScalar!(Unqual!T) ) {
				assert( false,
					"'" ~ transA ~ "', invalid value for 'transA' in matrix of type '" ~ T.stringof ~ "' copy." );
			} else {
				// assume transA == 'C'
				n *= ldb;
				auto be = b + n;
				while( b != be ) {
					blas.xaxpyc( m, alpha, a, lda, b, 1 );
					++ a; b += ldb;
				}
			}
		}
	}
	
}
